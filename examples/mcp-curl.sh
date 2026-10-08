#!/bin/sh
# Calling the PublicWWW MCP server directly. The server keeps no state between
# calls, so a tool can be called straight away, without the initialize handshake.
#   export PUBLICWWW_TOKEN=...      # https://publicwww.com/profile/api
set -e
MCP=https://api.publicwww.com/mcp
call () {
  curl -s "$MCP" -H "Authorization: Bearer $PUBLICWWW_TOKEN" \
       -H "Content-Type: application/json" -d "$1"
  echo
}

# The tools and their input schemas
call '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

# Plan and quota - spends nothing
call '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"account","arguments":{}}}'

# A search: three sites that load angular.min.js
call '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"search","arguments":{"query":"\"angular.min.js\"","rows":3}}}'
