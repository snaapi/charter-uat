package sign_up

import (
	"encoding/json"
	"strings"
	"tool/http"

	"github.com/snaapi/charter-uat/schema"
)

baseURL: string @tag(baseURL)

user: {
	email:    "uat-sign-up@example.com"
	name:     "UAT Sign Up"
	password: "uat-password-1"
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
			role:  "user"
		}
		meta: apiKey: =~"^crt_"
	}
	signedUp: data: id: signedUp.data.attributes.id
	sessionCookies: strings.Join(signup.response.header."Set-Cookie", "\n")
	sessionCookies: =~(schema.#SessionCookieName + "=")
}
