// Package exec is the shape of a command. It does not run anything.
package exec

// #command is a process argv and the strings that come back.
//
// argv is the process argv, with no shell. An empty list is not a command.
// mustSucceed defaults to true. success defaults to true: a caller that
// expects a non-zero exit sets both mustSucceed: false and success: false.
// mustSucceed: false on its own still lets the task finish.
#command: {
	argv: [string, ...string]
	mustSucceed: bool | *true
	success:     bool | *true
	stdout:      string
	stderr:      string
}
