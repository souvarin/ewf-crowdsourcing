note
	description: "Summary description for {SIGNUP_PAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SUPPORT_PAGE

inherit

	BASE_PAGE
		redefine
			initialize_controls
		end

create
	make

feature {NONE} -- Initialization

	initialize_controls
		local
			button1: WSF_BUTTON_CONTROL
			amount: WSF_INPUT_CONTROL
		do
			Precursor
			navbar.set_active (2)
			main_control.add_column (3)
			main_control.add_column (6)
			main_control.add_column (3)
			main_control.add_control (2, create {WSF_BASIC_CONTROL}.make_with_body ("h1", "", "Support project"))
			load_reward
			create form.make
			form.add_class ("form-horizontal")
			create amount.make ("")
			create amount_container.make ("Amount", amount)
			if attached reward ["amount"] as a then
				amount.append_attribute ("placeholder=%"min " + a.out + "$%"")
				amount_container.add_validator (create {WSF_AGENT_VALIDATOR [STRING_32]}.make (agent validate_amount, "Minimal amount is " + a.out))
			end
			form.add_control (amount_container)
			create button1.make ("OK")
			button1.add_class ("btn-primary")
			button1.set_click_event (agent handle_click)
			main_control.add_control (2, form)
			main_control.add_control (2, button1)
		end

feature -- Validation

	validate_amount (amount: STRING_32): BOOLEAN
		do
			Result := False
			if amount.is_double then
				if attached {DOUBLE} reward ["amount"] as a_amount and then amount.to_double >= a_amount then
					Result := True
				end
			end
		end

feature -- Implementation

	load_reward
		local
			query: SQL_QUERY [SQL_ENTITY]
			condition: SQL_CONDITIONS
		do
			if attached request.path_parameter ("reward_id") as id then
				create query.make ("rewards")
				query.set_fields (<<["id"], ["amount"], ["project_id"]>>)
				create condition.make_condition ("AND")
				condition ["id"].equals (id.string_representation)
				query.set_where (condition)
				reward := query.run (database).first
			else
				create reward.make
			end
		end

	process
		do
		end

feature --Events

	handle_click
		local
			funding: SQL_ENTITY
			city_id: INTEGER
			timestamp: DATE_TIME
		do
			form.validate
			if form.is_valid and attached current_user as user then
				create funding.make
				create timestamp.make_now
				funding ["user_id"] := user ["id"]
				funding ["project_id"] := reward ["project_id"]
				funding ["amount"] := amount_container.value.to_double
				funding ["timestamp"] := timestamp.formatted_out ("[0]dd-[0]mm-yyyy")
				funding ["reward_id"] := reward ["id"]
				funding.save (database, "fundings")
				if attached reward ["project_id"] as project_id then
					redirect ("/project/" + project_id.out)
				end
			end
		end

feature -- Properties

	reward: SQL_ENTITY

	amount_container: WSF_FORM_ELEMENT_CONTROL [STRING_32]

	form: WSF_FORM_CONTROL

end
