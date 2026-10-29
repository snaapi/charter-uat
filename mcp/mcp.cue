// Package mcp is the JSON-RPC and header shape of a streamable HTTP call.
// It does not open a connection.
package mcp

import (
	"encoding/json"
	"strings"
)

// #protocolVersion is the MCP protocol Charter 1.0.0-alpha.1 speaks.
#protocolVersion: "2025-06-18"

// #headers is the header set for one request.
//
// authorization and sessionId are omitted when they are empty, so an
// initialize call does not send a blank Authorization or Mcp-Session-Id.
// Values are strings. The HTTP task sends them as strings; tool/http
// returns response headers as lists.
#headers: {
	authorization:   string | *""
	sessionId:       string | *""
	protocolVersion: string | *#protocolVersion

	_authorization: authorization
	_sessionId:     sessionId
	_protocol:      protocolVersion
	header: {
		"Content-Type":         "application/json"
		Accept:                 "application/json, text/event-stream"
		"MCP-Protocol-Version": _protocol
		if _authorization != "" {
			Authorization: _authorization
		}
		if _sessionId != "" {
			"Mcp-Session-Id": _sessionId
		}
	}
}

// #initialize is the first request on a streamable HTTP session.
#initialize: {
	protocolVersion: string | *#protocolVersion
	name:            string | *"charter-uat"
	version:         string | *"0"
	id:              int | string | *1

	_protocol: protocolVersion
	_name:     name
	_version:  version
	_id:       id
	body: {
		jsonrpc: "2.0"
		id:      _id
		method:  "initialize"
		params: {
			protocolVersion: _protocol
			capabilities: {}
			clientInfo: {
				name:    _name
				version: _version
			}
		}
	}
}

// #initialized is the notification that follows a successful initialize.
// It has no id.
#initialized: {
	body: {
		jsonrpc: "2.0"
		method:  "notifications/initialized"
	}
}

// #toolsCall is a tools/call request. arguments is the tool's input object.
#toolsCall: {
	name: string
	arguments: _ | *{}
	id:         int | string | *1
	_name:      name
	_arguments: arguments
	_id:        id
	body: {
		jsonrpc: "2.0"
		id:      _id
		method:  "tools/call"
		params: {
			name:      _name
			arguments: _arguments
		}
	}
}

// #request is any other JSON-RPC call. notify omits id.
#request: {
	method: string
	params: _ | *null
	id:     int | string | *1
	notify: bool | *false

	_method: method
	_params: params
	_id:     id
	_notify: notify
	body: {
		jsonrpc: "2.0"
		method:  _method
		if !_notify {
			id: _id
		}
		if _params != null {
			params: _params
		}
	}
}

// #message is one JSON-RPC value from an HTTP body.
//
// A body that is already JSON is decoded as itself. A text/event-stream
// body contributes every non-empty `data:` line, and the last one is the
// message. Charter's stream writes a blank `data:` event before the JSON.
#message: {
	raw:    string
	_trim:  strings.TrimSpace(raw)
	_lines: strings.Split(raw, "\n")
	_payloads: [for line in _lines
		if strings.HasPrefix(strings.TrimSpace(line), "data:") {
			strings.TrimSpace(strings.TrimPrefix(strings.TrimSpace(line), "data:"))
		}]
	_json: [
		if strings.HasPrefix(_trim, "{") {_trim},
		for p in _payloads if p != "" {p},
	]
	body: json.Unmarshal(_json[len(_json)-1])
}
