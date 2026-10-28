package schema

// #SessionCookieName is the browser session cookie.
#SessionCookieName: "charter_auth_session_token"

// #JsonApiError is the closed document a failed HTTP call returns.
#JsonApiError: {
	errors: [...#JsonApiErrorItem]
}

#JsonApiErrorItem: {
	status:  string
	code:    string
	title:   string
	detail?: string
}

// #SignUp is the closed JSON:API document returned by email sign-up.
#SignUp: {
	data: {
		type: "user"
		id:   string
		attributes: {
			adminSince:    null
			banExpires:    null
			banReason:     null
			banned:        false
			createdAt:     string
			email:         string
			emailVerified: bool
			id:            string
			image:         null
			name:          string
			role:          string
			tokenVersion:  int
			updatedAt:     string
		}
	}
	meta: {
		accessToken: string
		apiKey:      string
		session: {
			createdAt:      string
			expiresAt:      string
			id:             string
			impersonatedBy: null
			ipAddress:      null
			updatedAt:      string
			userAgent:      null
			userId:         string
		}
		url: null
	}
}

// #Whoami is the closed document returned for a signed-in session.
#Whoami: {
	data: {
		type: "user"
		id:   string
		attributes: {
			email:         string
			emailVerified: bool
			name:          string
			role:          string
			roles: [...string]
		}
	}
}
