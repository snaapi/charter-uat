package healthz

import (
	"tool/http"
)

baseURL: string @tag(baseURL)

command: run: {
	healthz: http.Get & {
		url: "\(baseURL)/healthz"
		response: {
			statusCode: 200
			body:       "ok"
		}
	}
}
