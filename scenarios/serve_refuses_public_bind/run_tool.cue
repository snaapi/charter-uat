package serve_refuses_public_bind

import (
	"tool/exec"
)

baseURL: string @tag(baseURL)

command: run: {
	serve: exec.Run & {
		cmd: ["charter", "serve", "--host", "0.0.0.0"]
		mustSucceed: false
		success:     false
		stdout:      string
		stderr:      =~"COOKIE_SIGNING_KEY"
	}
}
