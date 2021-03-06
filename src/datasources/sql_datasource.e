note
	description: "Summary description for {SQL_DATASOURCE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SQL_DATASOURCE [T -> SQL_ENTITY create make_from_sqlite_result_row end]

inherit

	WSF_DATASOURCE [T]

feature {NONE}

	make (db: SQLITE_DATABASE)
		do
			database := db
		end

feature

	build_query
		deferred
		ensure
			attached query
		end

	data: LIST [T]
		local
			list: LINKED_LIST [T]
		do
			if not attached query then
				build_query
			end
			create list.make
			Result := list
			if attached query as a_query then
				Result := a_query.run (database)
			end
		end

feature

	query: detachable SQL_QUERY[T]

	database: SQLITE_DATABASE

end
