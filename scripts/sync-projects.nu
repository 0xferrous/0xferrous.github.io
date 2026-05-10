#!/usr/bin/env nix-shell
#! nix-shell -i nu -p nushell

export def quote [value: any] {
  $value | into string | to json
}

export def read_project [path: path] {
  let lines = (open --raw $path | lines)
  if ($lines | is-empty) { error make { msg: $"($path) empty file" } }
  if ($lines | first) != "+++" { error make { msg: $"($path) missing front matter" } }

  let markers = ($lines | enumerate | where item == "+++" | get index)
  if ($markers | length) < 2 { error make { msg: $"($path) missing closing front matter" } }

  let end = ($markers | get 1)
  let fm = ($lines | skip 1 | take ($end - 1) | str join (char nl))
  let body = ($lines | skip ($end + 2) | str join (char nl))

  { front_matter: ($fm | from toml), body: $body }
}

export def repo_name [link_to: string] {
  $link_to | split row "/" | last
}


def repo_slug [link_to: string] {
  let parts = ($link_to | split row "/" | where { |part| $part != "" })
  $"($parts | get 2)/($parts | get 3)"
}


export def repo_default_branch [repo: record] {
  ((($repo | get -o defaultBranchRef) | get -o name) | default "main")
}


def fetch_repo_readme [repo: record, repo_url: string] {
  let slug = (repo_slug $repo_url)
  let branch = (repo_default_branch $repo)
  let candidates = ["README.md", "README", "README.rst"]

  for filename in $candidates {
    let response = (http get --allow-errors --full --raw $"https://raw.githubusercontent.com/($slug)/($branch)/($filename)")
    if $response.status == 200 {
      return ($response.body | str trim)
    }
  }

  ""
}

export def strip_internal_anchor_links [body: string] {
  $body
  | str replace --all --regex '\[(?<text>[^\]]+)\]\(\s*#(?<anchor>[^)]+)\)' '$text'
  | str replace --all --regex '\[(?<text>[^\]]+)\]\(\s*\./#(?<anchor>[^)]+)\)' '$text'
  | str replace --all --regex '\[(?<text>[^\]]+)\]\(\s*\.\./#(?<anchor>[^)]+)\)' '$text'
}

export def strip_unsupported_code_languages [body: string] {
  $body
  | str replace --all --regex '(?m)^```text\s*$' '```'
}

export def rewrite_relative_github_links [body: string, repo: record, repo_url: string] {
  let slug = (repo_slug $repo_url)
  let branch = ((($repo | get -o defaultBranchRef) | get -o name) | default "main")
  let blob_base = $"https://github.com/($slug)/blob/($branch)/"
  let raw_base = $"https://raw.githubusercontent.com/($slug)/($branch)/"
  let image_replace = (["![$1](" $raw_base "$2$3)"] | str join "")
  let link_replace = (["[$1](" $blob_base "$2$3)"] | str join "")

  $body
  | str replace --all --regex '!\[([^\]]*)\]\((?:\./|\.\./)?([^):#]+)(#[^)]+)?\)' $image_replace
  | str replace --all --regex '\[([^\]]*)\]\((?:\./|\.\./)?([^):#]+)(#[^)]+)?\)' $link_replace
}

export def build_content [front_matter: record, body: string, repo: record, readme_body: string = ""] {
  let updated_date = ($repo.updatedAt | str substring 0..9)
  let populate_with_readme = (($front_matter.extra | default {} | get -o populate_with_readme) | default false)
  let body = if $populate_with_readme { (rewrite_relative_github_links (strip_unsupported_code_languages (strip_internal_anchor_links $readme_body)) $repo $repo.url) } else { $body }
  let extra = (
    $front_matter.extra
    | default {}
    | upsert link_to $repo.url
    | upsert updated_at $updated_date
  )

  let description = (
    if ($repo.description | default "" | str trim | is-empty) { "No description" } else { ($repo.description | str trim) }
  )

  let fm = (
    $front_matter
    | upsert title ($front_matter.title | default $repo.name)
    | upsert description $description
    | upsert date $updated_date
    | upsert extra $extra
  )

  [
    "+++"
    ($fm | to toml | str trim)
    "+++"
    ""
    $body
  ] | str join (char nl)
}

def log [msg: string] {
  print $msg
}

export def main [projects_dir: path, repositories_url: string = "https://raw.githubusercontent.com/0xferrous/.github/main/profile/repositories.json"] {
  let projects_dir = ($projects_dir | str trim --right --char "/")
  log $"syncing projects from ($repositories_url)"
  let repos = (http get $repositories_url)
  log $"fetched (( $repos | length )) repositories"
  let repos_by_name = ($repos | reduce -f {} { |repo acc| $acc | upsert $repo.name $repo })

  let project_paths = (
    glob $"($projects_dir)/*.md"
    | where { |path| ($path | path basename) != "_index.md" and not (($path | path basename) | str starts-with "project_") }
    | sort
  )

  let projects = (
    $project_paths
    | each { |path|
        let parsed = (read_project $path)
        let front_matter = $parsed.front_matter
        let link_to = (($front_matter.extra | default {} | get -o link_to) | default "")
        if ($link_to | is-empty) {
          null
        } else {
          let repo = ($repos_by_name | get -o (repo_name $link_to))
          if $repo == null {
            null
          } else {
            { path: $path, front_matter: $front_matter, body: $parsed.body, repo: $repo, link_to: $link_to }
          }
        }
      }
    | compact
    | sort-by { |item| $item.repo.updatedAt } --reverse
  )

  log $"found (( $projects | length )) project pages"

  for entry in ($projects | enumerate) {
    let item = $entry.item
    let needs_readme = (($item.front_matter.extra | default {} | get -o populate_with_readme) | default false)
    log $"updating ($item.path)" 
    if $needs_readme {
      log "  -> populating body from repo README"
    }
    let readme_body = if $needs_readme {
      (fetch_repo_readme $item.repo $item.link_to)
    } else {
      ""
    }
    let content = (build_content $item.front_matter $item.body $item.repo $readme_body)
    $content | save -f $item.path
  }

  log "done"
}
