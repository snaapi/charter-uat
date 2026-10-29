# charter-uat

CUE helpers for Charter acceptance tests. [CUE v0.17.1](https://github.com/cue-lang/cue/releases/tag/v0.17.1). Module path `github.com/snaapi/charter-uat`.

This repository is the utility module and nothing else. The tests live in the Charter repository, under `uat/`. That directory is its own CUE module. It depends on this one. It is not a git submodule, and this module does not contain those tests.

Charter starts the database and `charter serve`. A helper never sees a database URL, and it does not pass `--env-file`. The `charter` on `PATH` already points at the env file.

```cue
import "github.com/snaapi/charter-uat/exec"
import "github.com/snaapi/charter-uat/cli"
import "github.com/snaapi/charter-uat/mcp"
```

## Helpers

A helper is a definition. The test places it under `command: run` in its own package. `cue cmd` runs the tool value. Tasks in one command share no concrete fields with tasks in another command, because each test is its own package.

```cue
command: run: {
	user: cli.#user & {
		email:    "ada@example.test"
		name:     "Ada"
		password: "correct-horse-battery-staple"
	}
	key: cli.#apiKey & {
		$after: user
		email:  user.email
		label:  "uat"
	}
}
```

`user.email` is the input the caller set. Do not write `email: email` inside the struct that is defining `email`. CUE treats that as a reference to the field being defined, and `json.Marshal` then fails with `cannot convert incomplete value _ to JSON`.

`exec.#run` runs an argv. There is no shell. `mustSucceed` and `success` both default to true. A test that expects a non-zero exit sets both `mustSucceed: false` and `success: false`. `mustSucceed: false` alone still passes. Do not set `env` on the task: that replaces the process environment, and the `charter` wrapper on `PATH` disappears.

`cli` builds `charter --json <subcommand>`. `--json` is a global flag; without it the CLI prompts, and a prompt fails when stdin is not a terminal. Optional flags are omitted when the input is `""`, `null`, or `[]`. The runners decode stdout with `json.Unmarshal` into a closed struct (`#CliUser`, `#ApiKey`, `#Field`, `#Resource`, `#FieldBinding`, `#Permission`, `#Operator`, `#ServiceAccount`). An operator and a service account are the same kind of helper as a user.

A field binding's `defaultValue` is the CUE value sent as JSON. `default_value` is what the CLI prints back. Scalar defaults come back as JSON text: a string is quoted and a number is digits. Objects and arrays come back as JSON.

`mcp.#call` posts one JSON-RPC body to a streamable HTTP endpoint. `#initialize`, `#initialized`, and `#toolsCall` are the bodies. The response is either JSON or `text/event-stream`; `#message` keeps the last non-empty `data:` line. `mcpSessionId` is the `Mcp-Session-Id` response header, or `""` when that header is absent. `decode` defaults to true. An empty body, such as the 202 from `#initialized`, sets `decode: false` and leaves `message` null.

## Export

`*_tool.cue` files are invisible to `cue export`. Argv lists and JSON bodies live in the other files, so a caller can export them without running anything.

```sh
cue export ./cli -e '#userArgv & {email: "ada@example.test", name: "Ada"}'
```

## Boundary

`scripts/check-boundary` fails if a `.cue` or `.yaml` file under the module matches `DATABASE_URL`, `postgres://`, `sqlite:`, `psql`, or `sqlite3`.
