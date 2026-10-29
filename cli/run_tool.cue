package cli

import (
	"encoding/json"
	"tool/exec"
)

// Each helper is the tool/exec task, so a caller's $after orders it.
// The task fields match exec.#run: argv is the process argv, env is left
// unset, and stdout and stderr are strings.
//
// They are written out again here, in this struct, for two reasons.
// exec.#run is closed, so a conjunct cannot add email or id. And a field
// in this struct cannot see a field that was declared in another conjunct:
// json.Unmarshal(stdout) would report reference "stdout" not found.
//
// The copies (_email and the rest) are how a value is passed on. Writing
// email: email names the field being defined, and json.Marshal then fails
// with "cannot convert incomplete value _ to JSON".

#user: exec.Run & {
	$after?:     _
	email:       string
	name:        string
	password:    string | *""
	role:        string | null | *null
	mustSucceed: bool | *true
	success:     bool | *true
	stdout:      string
	stderr:      string | *""

	_email:    email
	_name:     name
	_password: password
	_role:     role
	argv: (#userArgv & {
		email:    _email
		name:     _name
		password: _password
		role:     _role
	}).argv
	cmd: argv
	_doc: json.Unmarshal(stdout) & #CliUser & {
		email: _email
		name:  _name
		role:  _role
	}
	id:       _doc.id
	operator: _doc.operator
	banned:   _doc.banned
}

#apiKey: exec.Run & {
	$after?:     _
	email:       string
	label:       string | *""
	expiresAt:   string | *""
	mustSucceed: bool | *true
	success:     bool | *true
	stdout:      string
	stderr:      string | *""

	_email:     email
	_label:     label
	_expiresAt: expiresAt
	argv: (#apiKeyArgv & {
		email:     _email
		label:     _label
		expiresAt: _expiresAt
	}).argv
	cmd: argv
	_doc: json.Unmarshal(stdout) & #ApiKey & {
		email: _email
	}
	id:   _doc.id
	name: _doc.name
	key:  _doc.key
}

#field: exec.Run & {
	$after?:      _
	name:         string
	field_type:   string
	display_name: string | null | *null
	description:  string | null | *null
	content_type: string | null | *null
	enum_values: [...string] | null | *null
	relations:   _ | null | *null
	mustSucceed: bool | *true
	success:     bool | *true
	stdout:      string
	stderr:      string | *""

	_name:        name
	_type:        field_type
	_display:     display_name
	_description: description
	_content:     content_type
	_enum:        enum_values
	_relations:   relations
	argv: (#fieldArgv & {
		name:         _name
		field_type:   _type
		display_name: _display
		description:  _description
		content_type: _content
		enum_values:  _enum
		relations:    _relations
	}).argv
	cmd: argv
	_doc: json.Unmarshal(stdout) & #Field & {
		name:         _name
		field_type:   _type
		display_name: _display
		description:  _description
		content_type: _content
		enum_values:  _enum
		relations:    _relations
	}
	id:         _doc.id
	created_at: _doc.created_at
	updated_at: _doc.updated_at
}

#resource: exec.Run & {
	$after?:                _
	name:                   string
	description:            string | null | *null
	enabled:                bool | *true
	read_only:              bool | *false
	allow_anonymous_access: bool | *false
	mustSucceed:            bool | *true
	success:                bool | *true
	stdout:                 string
	stderr:                 string | *""

	_name:        name
	_description: description
	_enabled:     enabled
	_readOnly:    read_only
	_anon:        allow_anonymous_access
	argv: (#resourceArgv & {
		name:                   _name
		description:            _description
		enabled:                _enabled
		read_only:              _readOnly
		allow_anonymous_access: _anon
	}).argv
	cmd: argv
	_doc: json.Unmarshal(stdout) & #Resource & {
		name:                   _name
		description:            _description
		enabled:                _enabled
		read_only:              _readOnly
		allow_anonymous_access: _anon
	}
	id:         _doc.id
	created_at: _doc.created_at
	updated_at: _doc.updated_at
	table:      _doc.table
}

#fieldBinding: exec.Run & {
	$after?:    _
	resource:   string
	field:      string
	required:   bool | *false
	sortable:   bool | *false
	searchable: bool | *false
	is_unique:  bool | *false
	// defaultValue is encoded as JSON on --default-value. The CLI prints
	// that byte string back for scalars (a string comes back quoted, a
	// number comes back as digits), and prints objects and arrays as JSON.
	// default_value is that printed value, so it is not the same field.
	defaultValue:   _ | *null
	validations:    _ | null | *null
	generated_from: _ | null | *null
	mustSucceed:    bool | *true
	success:        bool | *true
	stdout:         string
	stderr:         string | *""

	_resource:    resource
	_field:       field
	_required:    required
	_sortable:    sortable
	_searchable:  searchable
	_unique:      is_unique
	_default:     defaultValue
	_validations: validations
	_generated:   generated_from
	argv: (#fieldBindingArgv & {
		resource:       _resource
		field:          _field
		required:       _required
		sortable:       _sortable
		searchable:     _searchable
		is_unique:      _unique
		default_value:  _default
		validations:    _validations
		generated_from: _generated
	}).argv
	cmd: argv
	_doc: json.Unmarshal(stdout) & #FieldBinding & {
		required:       _required
		sortable:       _sortable
		searchable:     _searchable
		is_unique:      _unique
		validations:    _validations
		generated_from: _generated
	}
	default_value: _doc.default_value
	id:            _doc.id
	field_id:      _doc.field_id
	resource_id:   _doc.resource_id
	name:          _doc.name
	field_type:    _doc.field_type
	display_name:  _doc.display_name
	description:   _doc.description
	content_type:  _doc.content_type
	enum_values:   _doc.enum_values
	relations:     _doc.relations
	created_at:    _doc.created_at
	updated_at:    _doc.updated_at
	index:         _doc.index
}

#permission: exec.Run & {
	$after?:  _
	resource: string
	role:     string
	action:   string
	fields: [string, ...string]
	filters:     _ | null | *null
	checks:      _ | null | *null
	mustSucceed: bool | *true
	success:     bool | *true
	stdout:      string
	stderr:      string | *""

	_resource: resource
	_role:     role
	_action:   action
	_fields:   fields
	_filters:  filters
	_checks:   checks
	argv: (#permissionArgv & {
		resource: _resource
		role:     _role
		action:   _action
		fields:   _fields
		filters:  _filters
		checks:   _checks
	}).argv
	cmd: argv
	_doc: json.Unmarshal(stdout) & #Permission & {
		role:    _role
		action:  _action
		fields:  _fields
		filters: _filters
		checks:  _checks
	}
	id:          _doc.id
	resource_id: _doc.resource_id
	created_at:  _doc.created_at
	updated_at:  _doc.updated_at
}

#operator: exec.Run & {
	$after?:     _
	email:       string
	name:        string
	password:    string | *""
	mustSucceed: bool | *true
	success:     bool | *true
	stdout:      string
	stderr:      string | *""

	_email:    email
	_name:     name
	_password: password
	argv: (#operatorArgv & {
		email:    _email
		name:     _name
		password: _password
	}).argv
	cmd: argv
	_doc: json.Unmarshal(stdout) & #Operator & {
		email: _email
		name:  _name
	}
	id:          _doc.id
	admin_since: _doc.admin_since
	key:         _doc.key
}

#serviceAccount: exec.Run & {
	$after?:     _
	email:       string
	name:        string
	role:        string
	mustSucceed: bool | *true
	success:     bool | *true
	stdout:      string
	stderr:      string | *""

	_email: email
	_name:  name
	_role:  role
	argv: (#serviceAccountArgv & {
		email: _email
		name:  _name
		role:  _role
	}).argv
	cmd: argv
	_doc: json.Unmarshal(stdout) & #ServiceAccount & {
		email: _email
		name:  _name
		role:  _role
	}
	id:       _doc.id
	disabled: _doc.disabled
}
