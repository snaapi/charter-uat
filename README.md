# charter-uat

CUE contract for Charter. Each scenario is its own package under `scenarios/`. [CUE v0.17.1](https://github.com/cue-lang/cue/releases/tag/v0.17.1) defines and runs it (`cue cmd run`). Shared closed documents live in `schema/`.

A scenario is given `baseURL` and a `charter` binary on `PATH`. It does not receive a database URL. `scripts/check-boundary` fails if any CUE file contains `DATABASE_URL`, `postgres://`, `sqlite:`, `psql`, or `sqlite3`.

`scenarios/<name>/meta.cue` is hermetic. Read it with `cue export`; `*_tool.cue` files are not part of that evaluation.

```sh
cue export ./scenarios/healthz
```

```json
{"needsServer": true}
```

`needsServer: false` means the scenario starts `charter` itself. `serve_refuses_public_bind` is the one scenario that does.

## Run one scenario

From this repository, with CUE v0.17.1:

```sh
cue cmd run -t baseURL=http://127.0.0.1:3000 ./scenarios/healthz
```

The process that runs `cue cmd` must not have a database URL set. CLI steps call `charter` and do not pass an environment, so the child keeps this process's `PATH`. HTTP steps copy `Set-Cookie` into the next request's `Cookie` header.

## Scenarios

| Directory | Server | Proves |
| --- | --- | --- |
| `healthz` | yes | `GET /healthz` is 200 and `ok` |
| `sign_up` | yes | `POST /api/auth/sign-up/email` is 200 and sets `charter_auth_session_token` |
| `users_disable` | yes | sign up, `charter users disable <email> --json`, then `GET /api/auth/whoami` with that cookie is 401. A key-cache hit waits once, for 60 seconds |
| `serve_refuses_public_bind` | no | `charter serve --host 0.0.0.0` exits non-zero because a public bind needs a signing key |

## Add a scenario

Add it here first. The Charter repository only moves the submodule SHA.

1. Create `scenarios/<name>/` as its own CUE package.
2. Put `needsServer: bool` in `meta.cue` and nothing else that `cue export` would have to resolve.
3. Put `command: run` in `run_tool.cue`. Assert HTTP with unification (`response: statusCode: 200`) and `json.Unmarshal` against a closed struct. Assert a refused CLI with `tool/exec`, `mustSucceed: false`, and `success: false`.
4. Import shared shapes from `github.com/snaapi/charter-uat/schema`. Do not let one scenario's concrete fields sit in the same package as another's.
5. Put any YAML the scenario unifies against in `fixtures/`.
6. Run `scripts/check-boundary`.
