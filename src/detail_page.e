note
	description: "Summary description for {DETAIL_PAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DETAIL_PAGE

inherit

	BASE_PAGE
		redefine
			initialize_controls
		end

create
	make

feature -- Initialization

	initialize_controls
		do
			Precursor
			create main.make ("main")
			create side_bar.make ("side")
			create slider.make ("project_images")
			main.add_control (create {WSF_BASIC_CONTROL}.make_with_body ("h2", "", "Patrice needs a hat"))
			main.add_control (slider)
			slider.add_image ("http://media.pcgamer.com/files/2010/07/notch-interview-portrait-e1280400228443-590x365.jpg", "Notch")
			side_bar.add_control (create {WSF_BASIC_CONTROL}.make_with_body ("h2", "", "Goals"))
			main_control.add_control (main, 8)
			main_control.add_control (side_bar, 4)
			navbar.set_active (3)
		end

feature -- Implementation

	process
		do
		end

feature -- Properties


	main: WSF_MULTI_CONTROL [WSF_STATELESS_CONTROL]

	side_bar: WSF_MULTI_CONTROL [WSF_STATELESS_CONTROL]

	slider: WSF_SLIDER_CONTROL
end
