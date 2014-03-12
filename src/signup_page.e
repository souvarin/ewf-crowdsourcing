note
	description: "Summary description for {SIGNUP_PAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SIGNUP_PAGE

inherit

	BASE_PAGE
		redefine
			initialize_controls
		end

create
	make

feature {NONE}

	initialize_controls
		do
			Precursor
			navbar.set_active (4)
			main_control.add_column (3)
			main_control.add_column (6)
			main_control.add_column (3)
			create title.make_with_body ("h1", "", "Signup")
			main_control.add_control (2, title)
			create form.make_with_label_width (4)
			form.add_class ("form-horizontal")
			create name_container.make ("Username", create {WSF_INPUT_CONTROL}.make (""))
			name_container.add_validator (create {WSF_MIN_VALIDATOR [STRING_32]}.make (3, "Username must contain at least 3 characters"))
			name_container.add_validator (create {WSF_MAX_VALIDATOR [STRING_32]}.make (15, "Username can contain at most 15 characters"))
			name_container.add_validator (create {WSF_AGENT_VALIDATOR [STRING_32]}.make (agent check_username, "Username already taken"))
			form.add_control (name_container)
			create email_container.make ("Email", create {WSF_INPUT_CONTROL}.make (""))
			email_container.add_validator (create {WSF_EMAIL_VALIDATOR}.make ("Invalid email address"))
			form.add_control (email_container)
			create password2_container.make ("Password", create {WSF_PASSWORD_CONTROL}.make (""))
			password2_container.add_validator (create {WSF_MIN_VALIDATOR [STRING_32]}.make (6, "Password must contain at least 6 characters"))
			form.add_control (password2_container)
			create password3_container.make ("Repeat password", create {WSF_PASSWORD_CONTROL}.make (""))
			password3_container.add_validator (create {WSF_AGENT_VALIDATOR [STRING_32]}.make (agent compare_password, "Passwords do not match"))
			form.add_control (password3_container)
			main_control.add_control (2, form)
			create submit_button.make ("Register")
			submit_button.set_click_event (agent handle_click)
			submit_button.add_class (" btn-lg btn-primary btn-block")
			form.add_control (submit_button)
		end

	handle_click
		local
			user: SQL_ENTITY
			city_id: INTEGER
		do
			form.validate
			if form.is_valid then
				create user.make
				user ["username"] := name_container.value
				user ["password"] := password2_container.value
				user ["email"] := email_container.value
				user ["city_id"] := city_id
				user.save (database, "users")
				login (user)
			end
		end

	compare_password (input: STRING_32): BOOLEAN
		do
			Result := password2_container.value.same_string (input)
		end

	check_username (input: STRING_32): BOOLEAN
		local
			users_query: SQL_QUERY [SQL_ENTITY]
			condition: SQL_CONDITIONS
		do
			create users_query.make ("users")
			users_query.set_fields (<<["username"]>>)
			create condition.make_condition ("AND")
			condition ["username"].equals (input)
			users_query.set_where (condition)
			Result := users_query.count_total (database) = 0
		end

feature -- Implementation

	process
		do
		end

feature -- Properties

	form: WSF_FORM_CONTROL

	name_container: WSF_FORM_ELEMENT_CONTROL [STRING_32]

	email_container: WSF_FORM_ELEMENT_CONTROL [STRING_32]

	password2_container: WSF_FORM_ELEMENT_CONTROL [STRING_32]

	password3_container: WSF_FORM_ELEMENT_CONTROL [STRING_32]

	title: WSF_BASIC_CONTROL

	submit_button: WSF_BUTTON_CONTROL

end
