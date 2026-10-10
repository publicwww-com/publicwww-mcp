# PublicWWW MCP server

Search the source code (HTML, JavaScript, CSS) of hundreds of millions of websites
from an AI assistant: which sites load a script, use a library, carry a tracking id
or a widget - then save them as a cluster and pull contacts, social profiles or tag
ids out of their pages. [PublicWWW](https://publicwww.com) runs a remote MCP server:

```
https://api.publicwww.com/mcp
```

Nine tools: `search` (query, rows, page, snippets), `account` (plan, searches and
extraction points left today) and seven for [clusters](#clusters). Every account can
use it, a free one included - see [limits](https://publicwww.com/docs/mcp/limits/).

## Sign in

- **OAuth** - Claude, ChatGPT and Claude Code send you to PublicWWW to press Allow.
  Nothing to copy.
- **A token** - other clients send `Authorization: Bearer <token>`. Issue one on your
  [profile page](https://publicwww.com/profile/api) and keep it in the
  `PUBLICWWW_TOKEN` environment variable.

## Install

| Client | How |
|---|---|
| Claude (web, desktop) | Customize → Connectors → Add custom connector, URL above - [guide](https://publicwww.com/docs/mcp/claude/) |
| ChatGPT | Plugins → Add → Add custom MCP server, OAuth - [guide](https://publicwww.com/docs/mcp/chatgpt/) |
| Claude Code | the plugin below, or `claude mcp add --transport http publicwww https://api.publicwww.com/mcp` |
| Cursor | [![Install MCP Server](https://cursor.com/deeplink/mcp-install-dark.svg)](https://cursor.com/install-mcp?name=publicwww&config=eyJ1cmwiOiJodHRwczovL2FwaS5wdWJsaWN3d3cuY29tL21jcCIsImhlYWRlcnMiOnsiQXV0aG9yaXphdGlvbiI6IkJlYXJlciAke2VudjpQVUJMSUNXV1dfVE9LRU59In19) |
| VS Code | [![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Server-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://insiders.vscode.dev/redirect?url=vscode%3Amcp%2Finstall%3F%257B%2522name%2522%253A%2522publicwww%2522%252C%2522type%2522%253A%2522http%2522%252C%2522url%2522%253A%2522https%253A%252F%252Fapi.publicwww.com%252Fmcp%2522%252C%2522headers%2522%253A%257B%2522Authorization%2522%253A%2522Bearer%2520%2524%257Binput%253Apublicwww-token%257D%2522%257D%252C%2522inputs%2522%253A%255B%257B%2522type%2522%253A%2522promptString%2522%252C%2522id%2522%253A%2522publicwww-token%2522%252C%2522description%2522%253A%2522PublicWWW%2520token%2522%252C%2522password%2522%253Atrue%257D%255D%257D) |
| Gemini CLI | `gemini extensions install https://github.com/publicwww-com/publicwww-mcp` |
| Codex CLI | `codex mcp add publicwww --url https://api.publicwww.com/mcp --bearer-token-env-var PUBLICWWW_TOKEN` |
| Anything else | a config file from [`clients/`](clients/) |

The Cursor button reads the token from `PUBLICWWW_TOKEN`; VS Code asks for it once
and keeps it in its secret storage.

### Claude Code plugin

The MCP server (sign in with OAuth) and a skill that teaches the query syntax:

```
/plugin marketplace add publicwww-com/publicwww-mcp
/plugin install publicwww@publicwww
```

Then run `/mcp`, pick `publicwww` and choose Authenticate.

### Gemini CLI extension

```sh
gemini extensions install https://github.com/publicwww-com/publicwww-mcp
```

It asks for the token once and keeps it in the system keychain.

### Agent skill

[`skills/publicwww-search`](skills/publicwww-search/SKILL.md) is a skill in the open
Agent Skills format: how to write PublicWWW queries and use the tools. Copy the
folder into your agent's skills directory (for example `.agents/skills/` or
`~/.claude/skills/`).

## Query syntax, briefly

| Query | Finds |
|---|---|
| `"angular.min.js"` | that exact text in the page source |
| `bootstrap jquery` | both, anywhere on the page |
| `jquery (slick \| swiper)` | jquery and either of the two |
| `"amcharts.js" -bootstrap` | the first without the second |
| `site:de bootstrap` | only .de sites |
| `depth:all "math.min.js"` | inner pages too, not only home pages |

More: [query syntax](https://publicwww.com/docs/query-syntax/).

## Clusters

A cluster is a saved list of websites the assistant can build, combine and extract
data from.

| Tool | What it does |
|---|---|
| `list_clusters` | the account's clusters, newest first |
| `get_cluster` | a page of the domains in a cluster |
| `create_cluster` | from a search (`query`, costs one search) or a list of `domains` |
| `combine_clusters` | `and`, `or`, or `diff` (in the first, not in the second) of clusters |
| `extract_from_cluster` | values from the page source of every site: ready-made `presets` or your own `regex`, part after part |
| `rename_cluster` | a new name |
| `delete_cluster` | deletes for good; marked destructive, so the assistant asks you first |

Presets: `email`, `phone`, `whatsapp`, `telegram`, `skype`, `facebook`, `instagram`,
`twitter`, `linkedin`, `gtm`, `ga4`, `ua`, `hotjar`, `adsense`, `bitcoin`. Anything else
is a regular expression in slashes whose first group is the value, e.g.
`/data-site-id="([0-9]+)"/i`. Extraction spends the day's extraction points; an
account keeps up to 100 clusters.

Ask in plain words: *"Find sites that load static.hotjar.com, save them as a cluster
and get their contact emails and phones"* - the assistant runs `create_cluster`,
then `extract_from_cluster` with the `email` and `phone` presets until the cluster
is done. More: [tools](https://publicwww.com/docs/mcp/tools/).

## Calling it directly

[`examples/mcp-curl.sh`](examples/mcp-curl.sh) lists the tools, reads the account and
runs a search with plain `curl`. Streamable HTTP, JSON answers, no sessions - see
[for developers](https://publicwww.com/docs/mcp/developers/).

For scripts the [REST API](https://publicwww.com/docs/api/) is the simpler road - the
same search, clusters and token, with CSV and NDJSON. Small clients:
[Python](https://github.com/publicwww-com/publicwww-api-python),
[JavaScript](https://github.com/publicwww-com/publicwww-api-javascript),
[PHP](https://github.com/publicwww-com/publicwww-api-php),
[Go](https://github.com/publicwww-com/publicwww-api-go),
[Ruby](https://github.com/publicwww-com/publicwww-api-ruby).

## Documentation

[publicwww.com/docs/mcp](https://publicwww.com/docs/mcp/)

## License

MIT
