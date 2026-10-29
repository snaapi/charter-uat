package exec

import "tool/exec"

// #run is a tool/exec task. The value is the task, so a caller's $after
// orders this command against another command.
//
// env is left unset. Setting it replaces the process environment, and the
// charter wrapper on PATH disappears. The caller inherits PATH.
//
// stderr is empty when the process exits 0. tool/exec only reports stderr
// after a non-zero exit once stdout is captured.
#run: exec.Run & {
	argv: [string, ...string]
	$after?:     _
	cmd:         argv
	mustSucceed: bool | *true
	success:     bool | *true
	stdout:      string
	stderr:      string | *""
}
