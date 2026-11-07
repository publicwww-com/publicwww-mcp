---
name: publicwww-api
description: Call the PublicWWW REST API from code or the shell - search the source code (HTML, JavaScript, CSS) of web pages, save the sites as clusters, extract values from their pages. Use when a task needs which sites use a script, tag, library or tracking id through HTTP rather than MCP.
---

# PublicWWW REST API

PublicWWW indexes the source code of web pages: markup, scripts, stylesheets and the
text in them. A query is a fragment you expect to find there, or with `like:` a topic.

Base URL: `https://api.publicwww.com`. The map of the API is `GET /` and
`GET /openapi.json`, both without a key.

## Authentication

Send `Authorization: Bearer <key>` and nothing else: a key in the URL is refused.
Keys are issued at https://publicwww.com/profile/api. Read the key from the
environment, for example `PUBLICWWW_KEY`, and never print it or write it to a file
you commit. Searches and clusters need a paid plan; `/v1/account` works on any account.

```sh
curl -s -H "Authorization: Bearer $PUBLICWWW_KEY" https://api.publicwww.com/v1/account
```

The answer gives the plan, what is left today and `max_per_page`. It spends nothing
and does not count against the request rate, so call it first.

## Searching

```sh
curl -s -X POST https://api.publicwww.com/v1/search \
  -H "Authorization: Bearer $PUBLICWWW_KEY" -H "Content-Type: application/json" \
  -d '{"query": "\"googletagmanager.com/gtm.js\" site:de", "per_page": 20}'
```

GET with the same parameters works too; POST suits long queries. Query syntax:

- `"exact phrase"`: those words in that order; punctuation inside only separates words
- `a b`: both must appear
- `(a | b)`: either
- `-word`: must not appear
- `site:de`, `site:example.com`: a domain zone, or one site; `-site:com`, `-site:example.com`: leave them out
- `depth:all`: inner pages too, and `total` then counts pages; by default home pages, one per site
- `like:"topic"`, `like:example.com`: websites about a topic or like a given site; orders by
  similarity and removes nothing

Only `a-z`, `0-9` and `_` are searched; any other character separates words. Several
phrases in one query must all match. Results come most popular first, or most similar
first with `like:`. Since `like:` removes nothing, `total` then counts everything the
filters let through: limit it with a phrase or `site:` and read the first rows, as in
`"wp-content/plugins/elementor" like:"yoga studio"`. Full syntax:
https://publicwww.com/docs/query-syntax/

Read the answer before reporting a count: `total_capped` means more than the number
shown, so narrow the query rather than paging on; `truncated` means the plan cut the page, `index_complete: false` means not every
part of the index answered and the numbers are a lower bound. `rank` is the place by popularity, 1 being the most popular, an estimate with no guarantees, and `null` when unranked. `query_note` and
`original_query` tell you when the query was read differently from what you sent.

`snippets=1` adds fragments of source around the match and spends snippet quota as well.
It is worth asking for on a small page to check that a query finds what you mean, before
spending anything on a cluster. With `like:` alone the fragment is the page's `<title>`.

A common word alone finds big sites that merely mention it. To find sites by what they run,
look for a phrase only they have in their code. To find sites about a topic, use
`like:"online course" site:de` and read the first rows.

## Limits

- Each search spends one of the plan's daily searches. Quotas reset at midnight UTC.
- At most 10 requests a minute per account, shared with the MCP server. `X-Requests-Remaining`
  says what is left; `X-RateLimit-*` is the daily search quota, despite the name.
- On `429 too_many_requests` wait `Retry-After` seconds and repeat. On `429 quota_exceeded`
  repeating will not help until the reset.

## Clusters and extraction

A cluster is a saved list of sites. Create one from a search (one search, `limit` takes
only the first N) or from a list of domains (free):

```sh
curl -s -X POST https://api.publicwww.com/v1/clusters \
  -H "Authorization: Bearer $PUBLICWWW_KEY" -H "Content-Type: application/json" \
  -d '{"query": "\"googletagmanager.com/gtm.js\" site:de", "limit": 100, "name": "GTM in .de"}'
```

With `like:`, always pass `limit`: `{"query": "like:\"online course\" site:de", "limit": 100}`.
Since `like:` removes nothing, the cluster would otherwise take the plan's maximum.

The answer's `id` goes in the path. `/v1/clusters/combine` makes one from others (`and`,
`or`, `diff`), `/v1/clusters/{id}/signatures` finds code the sites share, as ready searches
for more like them. Both spend nothing. Clusters stay on the account until deleted, and an
account holds a limited number, so delete the temporary ones with `/v1/clusters/{id}/delete`.

Extraction pulls values out of every indexed page of each site in a cluster:

```sh
curl -s -X POST https://api.publicwww.com/v1/clusters/$ID/extract \
  -H "Authorization: Bearer $PUBLICWWW_KEY" -H "Content-Type: application/json" \
  -d '{"regex": ["/(GTM-[A-Z0-9]+)/"], "limit": 10}'
```

- `regex`: PCRE in slashes, the first capture group is the value, or the whole match
  without a group. A slash inside is written `\/`, or use pipes: `|https://example.com/([a-z]+)|i`.
  `presets`: ready-made ones, `GET /v1/clusters/presets` lists them with their expressions.
- The answer's `columns` names the columns, one per expression, and is not a parameter here;
  each row has `domain`, `values` in that order and `matches`. A value is found only where the
  source holds it, so expect sites with none: they are left out unless you pass `skip_empty=0`.
- `size` is the whole cluster, `scanned` the sites this call went through, `in_index` those in
  the index, `with_matches` those that gave a value.
- Each value found costs one point, a site with nothing a tenth, a site not in the index
  nothing. So try a small `limit` first: an expression that catches too much pays for
  every value. Every call is paid for, a repeat of the same sites too: keep the answer, and
  after a trial go on from `next_offset`.
- `limit` counts sites, up to 1000 a call. Continue with `offset` set to `next_offset`
  until it is `null`. `stopped` says why a call ended early.
- `format=csv` gives a file, comma separated (search results as CSV use a semicolon);
  `header=1` adds a header line, `delimiter` changes the separator.

## Errors

An error is `{"error": {"code": ..., "message": ...}}` with a matching HTTP status. Branch
on `code`, not the message: every code is listed in `GET /`.

- `401 missing_key`, `invalid_key`: no key, or one that does not exist.
- `403 plan_required`: the account has no paid plan.
- `400 page_too_deep`, `per_page_too_large`: past what the plan opens; the answer gives the limit.
- `400 format_not_available`: the format does not fit this endpoint. Search takes csv, tsv and txt,
  extract takes csv, a cluster's domains take txt.

## More

- API documentation: https://publicwww.com/docs/api/
- Ready-made clients: https://github.com/publicwww-com
