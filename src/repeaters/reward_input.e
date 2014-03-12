note
	description: "Summary description for {REWARD_INPUT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REWARD_INPUT

inherit

	WSF_MULTI_CONTROL [WSF_STATELESS_CONTROL]
		rename
			make as make_multicontrol
		end

create
	make

feature {NONE}

	make (a_parent: REWARD_INPUT_REPEATER)
		local
			button: WSF_BUTTON_CONTROL
		do
			parent := a_parent

			make_with_tag_name ("div")
			create button.make ("Remove this reward")
			button.set_click_event (agent remove)
			button.add_class ("pull-right")
			button.add_class ("btn-xs")
			button.add_class ("btn-danger")
			add_control (button)

			add_control (create {WSF_BASIC_CONTROL}.make_with_body ("h4", "", "Reward"))
			create form.make_with_label_width (3)
			create title_container.make ("Title", create {WSF_INPUT_CONTROL}.make (""))
			title_container.add_validator (create {WSF_AGENT_VALIDATOR [STRING_32]}.make (agent check_name, "Enter a valid title (between 3 and 50 characters)"))
			form.add_control (title_container)

			create description_container.make ("Description", create {WSF_TEXTAREA_CONTROL}.make (""))
			form.add_control (description_container)

			create price_container.make ("Price", create {WSF_INPUT_CONTROL}.make (""))
			form.add_control (price_container)


			add_control (form)
			add_control (create {WSF_BASIC_CONTROL}.make_with_body ("hr", "", ""))
		end
feature -- Validations

	check_name (input: STRING_32): BOOLEAN
		do
			Result := input.count >= 3 and input.count <= 50
		end

feature -- Events

	remove
	do
		parent.remove_control_by_id (control_id)
	end

feature {NONE}
	parent: REWARD_INPUT_REPEATER
	form: WSF_FORM_CONTROL

	title_container: WSF_FORM_ELEMENT_CONTROL [STRING_32]
	description_container: WSF_FORM_ELEMENT_CONTROL [STRING_32]
	price_container: WSF_FORM_ELEMENT_CONTROL [STRING_32]

end
