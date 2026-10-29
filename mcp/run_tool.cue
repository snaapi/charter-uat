package mcp

import (
	"encoding/json"
	"strings"
	"tool/http"
)

// #call posts one JSON-RPC body and decodes the response.
//
// The value is the tool/http task, so $after orders it against another
// task. decode defaults to true. Set it false for a response with an
// empty body: the initialized notification is answered with 202 and no
// body, and message stays null. The condition is the caller's bool, not
// the body. A test on the body would run before the response exists.
// mcpSessionId is empty when the response has no Mcp-Session-Id header.
#call: http.Post & {
	url:             string
	body:            _
	authorization:   string | *""
	sessionId:       string | *""
	protocolVersion: string | *#protocolVersion
	decode:          bool | *true
	$after?:         _

	_body:          body
	_authorization: authorization
	_sessionId:     sessionId
	_protocol:      protocolVersion
	_decode:        decode
	_header: (#headers & {
		authorization:   _authorization
		sessionId:       _sessionId
		protocolVersion: _protocol
	}).header
	request: {
		body:   json.Marshal(_body)
		header: _header
	}
	response: body: string

	message: *null | _
	if _decode {
		message: (#message & {raw: response.body}).body
	}
	mcpSessionId: strings.Join([
		for k, v in response.header if k == "Mcp-Session-Id" {
			strings.Join(v, "")
		},
	], "")
	statusCode: response.statusCode
}
