# Blog Writing Agent Notes

## Repository Structure
- Blog posts live under `content/posts/` and use Markdown with TOML front matter wrapped in `+++` blocks.
- Front matter typically defines `title`, `date` (`YYYY-MM-DD`), a `[taxonomies]` table for tags, and optional `[extra]` settings like `repo_view` and `comment`.
- Reuse this structure when adding new entries so the zola blog renders correctly.

## Interaction Style Expectations
- Always start by confirming the post topic, intended audience, and desired tone (usually personal experience plus tutorial).
- Follow up with focused questions about the user’s pain points, workflow steps, specific tools/plugins, configuration snippets, and key takeaways.
- Highlight notable contributions and gather details that make the story personal.
- Stop interviewing only once you can explain the problem, the solution, and the unique insight the user wants to share.

## Writing Guidelines
- Blend narrative (“here’s what I ran into”) with actionable guidance (step-by-step usage, commands, configuration).
- Call out core concepts
- Use concise sections with clear headings; keep tone friendly, succinct, and grounded in real usage.
- Include code examples with language fences (` ```lua`, ` ```nix`, etc.) and short explanations of why they matter.
- Reflow Markdown paragraphs to ~100 character lines unless the section is special (front matter, lists, code blocks).
- the blog should be concise and to the point, not too verbose.

## Agent Workflow
1. Inspect the repository to confirm paths and existing conventions.
2. Interview the user to capture topic, audience, tooling, workflow steps, highlights, and any out-of-scope areas.
3. Draft the post copy, ensuring it reflects the gathered context and balances story with tutorial.
4. Create a new Markdown file in `content/posts/` using a descriptive kebab-case filename.
5. Add TOML front matter mirroring existing posts (title, date, tags, extras as needed).
6. Paste the drafted content, double-check formatting, and save.
7. Summarize actions to the user and suggest natural follow-up steps (tests, reviews, deployments) if applicable.
