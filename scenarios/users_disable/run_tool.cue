package users_disable

import (
	"encoding/json"
	"strings"
	"tool/exec"
	"tool/http"

	"github.com/snaapi/charter-uat/schema"
)

baseURL: string @tag(baseURL)

user: {
	email:    "uat-users-disable@example.com"
	name:     "UAT Users Disable"
	password: "uat-password-1"
}

// A disabled session must come back unauthenticated. The key cache may
// still accept the cookie for up to the 60 seconds the CLI documents.
rejectedStatus: 401

#DisabledUser: {
	id:       string
	email:    string
	name:     string
	role:     string
	operator: bool
	banned:   true
}

command: run: {
	signup: http.Post & {
		url: "\(baseURL)/api/auth/sign-up/email"
		request: {
			body: json.Marshal({
				name:     user.name
				email:    user.email
				password: user.password
			})
			header: "Content-Type": "application/json"
		}
		response: {
			statusCode: 200
			body:       string
		}
	}
	signedUp: json.Unmarshal(signup.response.body) & schema.#SignUp & {
		data: attributes: {
			email: user.email
			name:  user.name
		}
	}
	sessionCookies: strings.Join(signup.response.header."Set-Cookie", "\n")
	sessionCookies: =~(schema.#SessionCookieName + "=")

	whoami: http.Get & {
		url: "\(baseURL)/api/auth/whoami"
		request: header: "Cookie": signup.response.header."Set-Cookie"
		response: {
			statusCode: 200
			body:       string
		}
	}
	identity: json.Unmarshal(whoami.response.body) & schema.#Whoami & {
		data: attributes: {
			email: user.email
			name:  user.name
		}
	}

	disable: exec.Run & {
		$after: whoami
		cmd: ["charter", "users", "disable", user.email, "--json"]
		stdout: string
		stderr: string
	}
	disabled: json.Unmarshal(disable.stdout) & #DisabledUser & {
		email: user.email
	}

	// cue cmd rejects a non-concrete `if`, so the one wait lives in this
	// process. An immediate rejection sleeps zero seconds.
	wait: exec.Run & {
		cmd: [
			"sh", "-c",
			"if [ \"$1\" != \"$2\" ]; then sleep 60; fi",
			"cache-wait",
			"\(probe.response.statusCode)",
			"\(rejectedStatus)",
		]
		stdout: string
	}
	probe: http.Get & {
		url:    "\(baseURL)/api/auth/whoami"
		$after: disable
		request: header: "Cookie": signup.response.header."Set-Cookie"
		response: {
			statusCode: int
			body:       string
		}
	}
	whoamiAfter: http.Get & {
		$after: wait
		url:    "\(baseURL)/api/auth/whoami"
		request: header: "Cookie": signup.response.header."Set-Cookie"
		response: {
			statusCode: rejectedStatus
			body:       string
		}
	}
	rejected: json.Unmarshal(whoamiAfter.response.body) & schema.#JsonApiError & {
		errors: [{status: "\(rejectedStatus)"}, ...]
	}
}
