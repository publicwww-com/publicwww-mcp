---
name: publicwww-search
description: Search the source code (HTML, JavaScript, CSS) of hundreds of millions of websites with PublicWWW - find which sites use a script, library, tracking id, widget, meta tag or any code fragment, save them as clusters and extract contacts, social profiles or tag ids from their pages. Use when the user asks which or how many websites contain some code, wants a list of such sites, or wants data pulled out of those sites.
---

# Searching page source with PublicWWW

PublicWWW indexes the source code of web pages, not the text visitors see. A query
is the fragment of markup, script or stylesheet you expect to find in the page
source. Results are sites, ranked by popularity.

The search runs through the PublicWWW MCP server (`https://api.publicwww.com/mcp`,
tools `search`, `account` and seven cluster tools) or the REST API
(`https://api.publicwww.com/v1/search`, `/v1/clusters`).

## Writing the query

| Syntax | Meaning | Example |
|---|---|---|
| `"..."` | Exact phrase - those characters in that order. Use it almost always. | `"angular.min.js"` |
| `"..."~N` | Phrase whose words may be up to N apart | `"gtag config"~5` |
| `a b` | All of the words or phrases, in any order | `bootstrap jquery` |
| `distance:N` | The words close together | `fbq distance:5 init` |
| `( \| )` | Either side; brackets group | `jquery (slick \| swiper)` |
| `-x` | Exclude pages containing x | `"amcharts.js" -bootstrap` |
| `\"` | A quote inside a phrase | `"<html lang=\"fr\">"` |
| `site:` | One top-level domain, or one site's pages | `site:de bootstrap`, `site:example.com` |
| `depth:all` | Inner pages too (by default only home pages) | `depth:all "math.min.js"` |
| `ip:` | One address or a class C subnet | `ip:160.153.136.* bootstrap` |

Tips:

- Search for the code, not a description of it: a file name (`"hotjar-"`), an
  id prefix (`"UA-12345"`), a function call (`"fbq('init'"`), a meta tag.
- Quote anything with punctuation - dots, slashes and dashes split words otherwise.
- Prefer the most specific fragment; a common word matches millions of pages.
- `site:<tld>` narrows by country; `depth:all` when the code lives on inner pages.

## Using the tools

- `search` - `query` (required), `rows` (20 by default, up to the plan's rows per
  query), `page`, `snippets` (true adds up to three fragments of source around the
  match for each site; spends a snippet search on paid plans).
- `account` - plan, searches used and left today, limits. Spends nothing; call it
  when the user asks about quota or a search is refused.
- Each search counts against the account's daily searches. Ask for a small number
  of rows first and widen only if the user needs more.
- `total` is the number of matching sites; `truncated` means the plan cut the list
  short; `rank: null` means the site has no rank.
- Refusals come back as tool errors with a code: `quota_exceeded` (come back after
  midnight UTC), `too_many_requests` (wait `retry_after` seconds), `page_too_deep`.

## Clusters and extraction

A cluster is a saved list of websites. Use clusters when the user wants something
from the sites themselves - emails, phones, social profiles, analytics or tag ids -
or wants to compare two sets of sites.

- `create_cluster` - from a search (`query`, same syntax as `search`; costs one
  search, a repeat within a day is free) or from a list (`domains`, names or urls;
  only sites in the index are kept). Optional `name`.
- `list_clusters`, `get_cluster` (`cluster`, `page`, `rows`) - read only, spend
  nothing.
- `combine_clusters` - `operation` `and` (in every cluster), `or` (in any) or
  `diff` (in the first but not the second, exactly two), `clusters` - the ids.
- `extract_from_cluster` - `cluster`, `presets` and/or `regex`, `offset`, `limit`,
  `include_empty`. Prefer presets by name: `email`, `phone`, `whatsapp`,
  `telegram`, `skype`, `facebook`, `instagram`, `twitter`, `linkedin`, `gtm`,
  `ga4`, `ua`, `hotjar`, `adsense`, `bitcoin`. Otherwise a PCRE in slashes whose
  first capture group is the value, e.g. `/data-site-id="([0-9]+)"/i`; up to ten
  expressions, one column each. It works in parts: call again with `offset` set to
  `next_offset` until it is null. Each site found costs as many extraction points
  as values found, 0.1 if none - try a small `limit` first on a big cluster.
- `rename_cluster` - `cluster`, `name`.
- `delete_cluster` - deletes for good and cannot be undone. Always ask the user
  before calling it, naming the cluster.
- An account keeps up to 100 clusters; past that `create_cluster` and
  `combine_clusters` answer `cluster_limit` - offer to delete old ones, do not
  delete on your own. Free accounts: up to 100 domains in a cluster and 100
  extraction points a day. `extract_quota_exceeded` - the day's points are used
  up.

Example: "emails of sites that use Hotjar" - `create_cluster` with query
`"static.hotjar.com"`, then `extract_from_cluster` with presets `["email"]`,
following `next_offset`.

Documentation: https://publicwww.com/docs/query-syntax/, https://publicwww.com/docs/mcp/
and https://publicwww.com/docs/clusters/
