#!/usr/bin/env nix-shell
#! nix-shell -i nu -p nushell

def quote [value: any] {
  $value | into string | to json
}

def read_project [path: path] {
  let lines = (open --raw $path | lines)
  if ($lines | is-empty) { error make { msg: $"($path) empty file" } }
  if ($lines | first) != "+++" { error make { msg: $"($path) missing front matter" } }

  let markers = ($lines | enumerate | where item == "+++" | get index)
  if ($markers | length) < 2 { error make { msg: $"($path) missing closing front matter" } }

  let end = ($markers | get 1)
  let fm = ($lines | skip 1 | take ($end - 1) | str join (char nl))
  let body = ($lines | skip ($end + 1) | str join (char nl))

  { front_matter: ($fm | from toml), body: $body }
}

def repo_name [link_to: string] {
  $link_to | split row "/" | last
}

def build_content [front_matter: record, body: string, repo: record] {
  let updated_date = ($repo.updatedAt | str substring 0..9)
  let extra = (
    $front_matter.extra
    | default {}
    | upsert link_to $repo.url
    | upsert updated_at $updated_date
  )

  let description = (
    if ($repo.description | default "" | str trim | is-empty) { "No description" } else { ($repo.description | str trim) }
  )

  [
    "+++"
    $"title = (quote ($front_matter.title | default $repo.name))"
    $"description = (quote $description)"
    $"date = (quote $updated_date)"
    ""
    "[extra]"
    ...(
      $extra
      | transpose key value
      | sort-by key
      | each { |row| $"($row.key) = (quote $row.value)" }
    )
    "+++"
    ""
    ($body | str trim)
    ""
  ] | str join (char nl)
}

export def main [projects_dir: path, repositories_url: string = "https://raw.githubusercontent.com/0xferrous/.github/main/profile/repositories.json"] {
  let projects_dir = ($projects_dir | str trim --right --char "/")
  let repos = (http get $repositories_url)
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
            { path: $path, front_matter: $front_matter, body: $parsed.body, repo: $repo }
          }
        }
      }
    | compact
    | sort-by { |item| $item.repo.updatedAt } --reverse
  )

  for entry in ($projects | enumerate) {
    let item = $entry.item
    let content = (build_content $item.front_matter $item.body $item.repo)
    $content | save -f $item.path
  }
}
