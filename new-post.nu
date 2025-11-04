#!/usr/bin/env nu

# Create a new blog post for Zola
def main [
    title: string  # The title of the blog post
    --tags (-t): list<string> = []  # Optional tags for the post
] {
    # Generate slug from title (lowercase, replace spaces with hyphens)
    let slug = ($title
        | str downcase
        | str replace --all ' ' '-'
        | str replace --all --regex '[^a-z0-9-]' '')

    # Get current date
    let date = (date now | format date '%Y-%m-%d')

    # Create filename
    let filename = $"content/posts/($slug).md"

    # Check if file already exists
    if ($filename | path exists) {
        print $"Error: File ($filename) already exists!"
        exit 1
    }

    # Format tags for TOML
    let tags_str = if ($tags | is-empty) {
        "[]"
    } else {
        let tag_list = ($tags | each { |tag| $'"($tag)"' } | str join ', ')
        $"[($tag_list)]"
    }

    # Create the post with front matter
    let content = $"+++
title = \"($title)\"
date = \"($date)\"

[taxonomies]
tags = ($tags_str)

[extra]
repo_view = true
comment = true
+++

Write your post content here...

<!-- more -->

## Section 1

Your content...
"

    # Write the file
    $content | save $filename

    print $"Created new post: ($filename)"
    print "Edit the file to add content."
}
