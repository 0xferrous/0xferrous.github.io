#!/usr/bin/env nix-shell
#! nix-shell -i nu -p nushell

use ./sync-projects.nu *

def fail [msg: string] {
  error make { msg: $msg }
}


def assert_equal [name: string, actual: any, expected: any] {
  if $actual != $expected {
    fail $"($name) failed\nexpected: ($expected | to json)\nactual:   ($actual | to json)"
  }
}


def test_read_project_preserves_body [] {
  let path = "/tmp/sync-projects-test.md"
  let sample = "+++\ntitle = \"demo\"\ndescription = \"desc\"\n+++\n\nfirst line\n\nsecond line\n"
  $sample | save -f $path

  let parsed = (read_project $path)
  assert_equal "read_project body" $parsed.body "first line\n\nsecond line"
}


def test_build_content_updates_metadata_and_keeps_body [] {
  let front_matter = { title: "demo", description: "old", extra: { foo: "bar" } }
  let repo = {
    name: "demo-repo"
    url: "https://github.com/0xferrous/demo-repo"
    description: "New desc"
    updatedAt: "2026-05-10T12:34:56Z"
    defaultBranchRef: { name: "main" }
  }
  let body = "first line\n\nsecond line"

  let actual = (build_content $front_matter $body $repo)
  let expected = "+++\ntitle = \"demo\"\ndescription = \"New desc\"\ndate = \"2026-05-10\"\n\n[extra]\nfoo = \"bar\"\nlink_to = \"https://github.com/0xferrous/demo-repo\"\nupdated_at = \"2026-05-10\"\n+++\n\nfirst line\n\nsecond line"

  assert_equal "build_content output" $actual $expected
}


def test_build_content_uses_readme_when_flag_set [] {
  let front_matter = { title: "demo", description: "old", extra: { foo: "bar", populate_with_readme: true } }
  let repo = {
    name: "demo-repo"
    url: "https://github.com/0xferrous/demo-repo"
    description: "New desc"
    updatedAt: "2026-05-10T12:34:56Z"
    defaultBranchRef: { name: "main" }
  }

  let actual = (build_content $front_matter "should not stay" $repo "README body")
  let expected = "+++\ntitle = \"demo\"\ndescription = \"New desc\"\ndate = \"2026-05-10\"\n\n[extra]\nfoo = \"bar\"\npopulate_with_readme = true\nlink_to = \"https://github.com/0xferrous/demo-repo\"\nupdated_at = \"2026-05-10\"\n+++\n\nREADME body"

  assert_equal "build_content README populate" $actual $expected
}


def test_strip_internal_anchor_links [] {
  let body = "See [one](#freedesktoporg-notifications-api-coverage) and [two](./#behaviordetails) and [three](../#niri--wispd-microvm-qemu)."
  let actual = (strip_internal_anchor_links $body)
  let expected = "See one and two and three."
  assert_equal "strip_internal_anchor_links" $actual $expected
}


def test_strip_unsupported_code_languages [] {
  let body = "```text\nhello\n```\n"
  let actual = (strip_unsupported_code_languages $body)
  let expected = "```\nhello\n```\n"
  assert_equal "strip_unsupported_code_languages" $actual $expected
}


def test_rewrite_relative_github_links [] {
  let repo = {
    url: "https://github.com/0xferrous/demo-repo"
    defaultBranchRef: { name: "main" }
  }
  let body = "See [docs](./docs/ARCHITECTURE.md) and ![img](./demo.png)"
  let actual = (rewrite_relative_github_links $body $repo $repo.url)
  let expected = "See [docs](https://github.com/0xferrous/demo-repo/blob/main/docs/ARCHITECTURE.md) and ![img](https://raw.githubusercontent.com/0xferrous/demo-repo/main/demo.png)"
  assert_equal "rewrite_relative_github_links" $actual $expected
}


def test_repo_default_branch [] {
  let repo = { defaultBranchRef: { name: "main" } }
  assert_equal "repo_default_branch" (repo_default_branch $repo) "main"
}


export def main [] {
  test_read_project_preserves_body
  test_build_content_updates_metadata_and_keeps_body
  test_build_content_uses_readme_when_flag_set
  test_strip_internal_anchor_links
  test_strip_unsupported_code_languages
  test_rewrite_relative_github_links
  test_repo_default_branch
  print "ok"
}
