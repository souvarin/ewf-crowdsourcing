note
	description: "simple application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit

	WSF_ROUTED_SERVICE
		rename
			execute as execute_router
		end

	WSF_FILTERED_SERVICE

	WSF_DEFAULT_SERVICE
		redefine
			initialize
		end

	WSF_FILTER
		rename
			execute as execute_router
		end

create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			connect_to_database
			initialize_router
			initialize_filter
			Precursor
			set_service_option ("port", 7070)
		end

feature -- Router and Filter

	create_filter
			-- Create `filter'
		local
			f, l_filter: detachable WSF_FILTER
		do
			l_filter := Void

				-- Maintenance
			create {WSF_MAINTENANCE_FILTER} f
			f.set_next (l_filter)
			l_filter := f

				-- Logging
			create {WSF_LOGGING_FILTER} f
			f.set_next (l_filter)
			l_filter := f
			filter := l_filter
		end

	setup_filter
			-- Setup `filter'
		local
			f: WSF_FILTER
		do
			from
				f := filter
			until
				not attached f.next as l_next
			loop
				f := l_next
			end
			f.set_next (Current)
		end

	setup_router
		do
			map_agent_uri ("/", agent execute_hello, Void)
			map_agent_uri ("/grid", agent execute_grid, Void)
			map_agent_uri ("/project/sample", agent execute_sample_project, Void)

				-- NOTE: you could put all those files in a specific folder, and use WSF_FILE_SYSTEM_HANDLER with "/"
				-- this way, it handles the caching and so on
			router.handle_with_request_methods ("/assets", create {WSF_FILE_SYSTEM_HANDLER}.make_hidden ("assets"), router.methods_GET)
		end

feature -- Helper: mapping

	map_agent_uri (a_uri: READABLE_STRING_8; a_action: like {WSF_URI_AGENT_HANDLER}.action; rqst_methods: detachable WSF_REQUEST_METHODS)
		do
			router.map_with_request_methods (create {WSF_URI_MAPPING}.make (a_uri, create {WSF_URI_AGENT_HANDLER}.make (a_action)), rqst_methods)
		end

feature -- Execution

	execute_hello (request: WSF_REQUEST; response: WSF_RESPONSE)
		local
			page: EMPTY_PAGE
		do
				-- To send a response we need to setup, the status code and
				-- the response headers.
			create page.make (database, request, response)
			page.execute
		end

	execute_grid (request: WSF_REQUEST; response: WSF_RESPONSE)
		local
			page: GRID_PAGE
		do
			create page.make (database, request, response)
			page.execute
		end

	execute_sample_project (request: WSF_REQUEST; response: WSF_RESPONSE)
		local
			page: DETAIL_PAGE
		do
			create page.make (database, request, response)
			page.execute
		end

feature --DB

	connect_to_database
		do
			create database.make_open_read_write ("Crowdsourcing.db")
		end

	database: SQLITE_DATABASE

end
