# PublicWWW

The `publicwww` MCP server searches the source code (HTML, JavaScript, CSS) of
hundreds of millions of websites. Use its `search` tool when the user asks which
or how many websites contain some code - a script, library, tracking id, widget or
meta tag - `account` for the plan and the searches left today, and `read_docs`
for PublicWWW's own documentation and prices (syntax, API, limits, plans). The cluster
tools (`create_cluster`, `extract_from_cluster`, `combine_clusters`, ...) save sites
as a list and pull contacts, social profiles or tag ids out of their pages; ask the
user before `delete_cluster`.

Write the query as the code to find, quoted: `"angular.min.js"`. The
`publicwww-search` skill has the full query syntax.
