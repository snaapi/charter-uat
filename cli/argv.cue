// Package cli builds charter argv lists and the closed documents those
// commands print with --json. Nothing here runs a process.
package cli

import (
	"encoding/json"
	"strings"
)

// #CliUser is `charter --json users create`.
#CliUser: {
	id!:       string
	email!:    string
	name!:     string
	role!:     string | null
	operator!: bool
	banned!:   bool
}

// #ApiKey is `charter --json api-keys create`. name is the label.
#ApiKey: {
	id!:    string
	email!: string
	name!:  string | null
	key!:   string
}

// #Field is `charter --json fields create`.
#Field: {
	id!:           string
	name!:         string
	field_type!:   string
	display_name!: string | null
	description!:  string | null
	content_type!: string | null
	enum_values!:  _ | null
	relations!:    _ | null
	created_at!:   string
	updated_at!:   string
}

// #Resource is `charter --json resources create`.
#Resource: {
	id!:                     string
	name!:                   string
	description!:            string | null
	enabled!:                bool
	read_only!:              bool
	allow_anonymous_access!: bool
	created_at!:             string
	updated_at!:             string
	table!:                  string
}

// #FieldBinding is `charter --json resources attach`.
#FieldBinding: {
	id!:             string
	field_id!:       string
	resource_id!:    string
	name!:           string
	field_type!:     string
	required!:       bool
	sortable!:       bool
	searchable!:     bool
	is_unique!:      bool
	display_name!:   string | null
	description!:    string | null
	content_type!:   string | null
	default_value!:  _ | null
	enum_values!:    _ | null
	validations!:    _ | null
	generated_from!: _ | null
	relations!:      _ | null
	created_at!:     string
	updated_at!:     string
	index!:          string | null
}

// #Permission is `charter --json permissions create`.
#Permission: {
	id!:          string
	resource_id!: string
	role!:        string
	action!:      string
	fields!: [...string]
	filters!:    _ | null
	checks!:     _ | null
	created_at!: string
	updated_at!: string
}

// #Operator is `charter --json admin create`.
#Operator: {
	id!:          string
	email!:       string
	name!:        string
	admin_since!: string
	key!:         string
}

// #ServiceAccount is `charter --json service-account create`.
#ServiceAccount: {
	id!:       string
	email!:    string
	name!:     string
	role!:     string
	disabled!: bool
}

// Every argv list starts with charter, then --json, then the subcommand.
// --json is a global flag. Without it the CLI prompts, and a prompt fails
// when stdin is not a terminal.
//
// Optional flags are omitted when the input is "" or null or []. An empty
// --role or an empty --fields is never passed.

#userArgv: {
	email:    string
	name:     string
	password: string | *""
	role:     string | null | *null
	argv: [
		"charter", "--json", "users", "create",
		"--email", email,
		"--name", name,
		if password != "" {"--password"},
		if password != "" {password},
		if role != null {"--role"},
		if role != null {role},
	]
}

#apiKeyArgv: {
	email:     string
	label:     string | *""
	expiresAt: string | *""
	argv: [
		"charter", "--json", "api-keys", "create",
		"--email", email,
		if label != "" {"--label"},
		if label != "" {label},
		if expiresAt != "" {"--expires-at"},
		if expiresAt != "" {expiresAt},
	]
}

#fieldArgv: {
	name:         string
	field_type:   string
	display_name: string | null | *null
	description:  string | null | *null
	content_type: string | null | *null
	enum_values: [...string] | null | *null
	relations:      _ | null | *null
	_enumFlag:      *"" | string
	_relationsFlag: *"" | string
	if enum_values != null {
		if len(enum_values) > 0 {
			_enumFlag: strings.Join(enum_values, ",")
		}
	}
	if relations != null {
		_relationsFlag: json.Marshal(relations)
	}
	argv: [
		"charter", "--json", "fields", "create", name,
		"--type", field_type,
		if display_name != null {"--display-name"},
		if display_name != null {display_name},
		if description != null {"--description"},
		if description != null {description},
		if content_type != null {"--content-type"},
		if content_type != null {content_type},
		if _enumFlag != "" {"--enum-values"},
		if _enumFlag != "" {_enumFlag},
		if _relationsFlag != "" {"--relations"},
		if _relationsFlag != "" {_relationsFlag},
	]
}

#resourceArgv: {
	name:                   string
	description:            string | null | *null
	enabled:                bool | *true
	read_only:              bool | *false
	allow_anonymous_access: bool | *false
	argv: [
		"charter", "--json", "resources", "create", name,
		if description != null {"--description"},
		if description != null {description},
		if !enabled {"--disabled"},
		if read_only {"--read-only"},
		if allow_anonymous_access {"--allow-anonymous"},
	]
}

#fieldBindingArgv: {
	resource:         string
	field:            string
	required:         bool | *false
	sortable:         bool | *false
	searchable:       bool | *false
	is_unique:        bool | *false
	default_value:    _ | null | *null
	validations:      _ | null | *null
	generated_from:   _ | null | *null
	_defaultFlag:     *"" | string
	_validationsFlag: *"" | string
	_generatedFlag:   *"" | string
	if default_value != null {
		_defaultFlag: json.Marshal(default_value)
	}
	if validations != null {
		_validationsFlag: json.Marshal(validations)
	}
	if generated_from != null {
		_generatedFlag: json.Marshal(generated_from)
	}
	argv: [
		"charter", "--json", "resources", "attach", resource, field,
		if required {"--required"},
		if sortable {"--sortable"},
		if searchable {"--searchable"},
		if is_unique {"--unique"},
		if _defaultFlag != "" {"--default-value"},
		if _defaultFlag != "" {_defaultFlag},
		if _validationsFlag != "" {"--validations"},
		if _validationsFlag != "" {_validationsFlag},
		if _generatedFlag != "" {"--generated-from"},
		if _generatedFlag != "" {_generatedFlag},
	]
}

#permissionArgv: {
	resource: string
	role:     string
	action:   string
	fields: [string, ...string]
	filters:      _ | null | *null
	checks:       _ | null | *null
	_filtersFlag: *"" | string
	_checksFlag:  *"" | string
	if filters != null {
		_filtersFlag: json.Marshal(filters)
	}
	if checks != null {
		_checksFlag: json.Marshal(checks)
	}
	argv: [
		"charter", "--json", "permissions", "create", resource, role, action,
		"--fields", strings.Join(fields, ","),
		if _filtersFlag != "" {"--filters"},
		if _filtersFlag != "" {_filtersFlag},
		if _checksFlag != "" {"--checks"},
		if _checksFlag != "" {_checksFlag},
	]
}

#operatorArgv: {
	email:    string
	name:     string
	password: string | *""
	argv: [
		"charter", "--json", "admin", "create",
		"--email", email,
		"--name", name,
		if password != "" {"--password"},
		if password != "" {password},
	]
}

#serviceAccountArgv: {
	email: string
	name:  string
	role:  string
	argv: [
		"charter", "--json", "service-account", "create",
		"--email", email,
		"--name", name,
		"--role", role,
	]
}
