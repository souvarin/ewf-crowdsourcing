note
	description: "Summary description for {PROJECTS_DATASOURCE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PROJECTS_DATASOURCE

inherit

	SQL_DATASOURCE [SQL_ENTITY]
		redefine
			state,
			set_state
		end

create
	make_default

feature

	make_default (db: SQLITE_DATABASE)
		do
			make (db)
			search_text := ""
		end

	set_query (q: STRING)
		do
			search_text := q
		end

	set_city (id: INTEGER_64)
		do
			city := id
		end

	set_category (id: INTEGER_64)
		do
			category := id
		end

	build_query
		local
			cond: SQL_CONDITIONS
			a_query: SQL_QUERY [SQL_ENTITY]
			thumbnails: SQL_QUERY [SQL_ENTITY]
			thumbnails_cond: SQL_CONDITIONS
		do
				-- Subquery selecting one thumbnail per project
			create thumbnails.make ("media")
			thumbnails.set_fields (<<["url"], ["project_id"]>>)
			create thumbnails_cond.make_condition ("AND")
			thumbnails.set_where (thumbnails_cond)
			thumbnails_cond ["tag"].equals ("thumbnail")
			thumbnails.set_order_by ("project_id")
			thumbnails.set_alias ("thumbnail")

				--Load project with thumbnails
			create a_query.make ("projects")
			a_query.set_fields (<<["id", "projects.id"], ["title", "projects.title"], ["cname", "categories.name"], ["image", "thumbnail.url"]>>)
				--Left join category table
			a_query.left_join ("categories", "categories.id = category_id")
				--Left join thumbnail subquery
			a_query.left_join (thumbnails, "projects.id = thumbnail.project_id")
			create cond.make_condition ("AND")
			a_query.set_where (cond)

				-- Filter projects by search text
			if not search_text.is_empty then
				cond ["projects.title"].contains (search_text)
			end

				-- Filter category by using the nested set model http://en.wikipedia.org/wiki/Nested_set_model
			cond.add ("categories.left >= (SELECT left FROM categories as c WHERE c.id = " + category.out + ")")
			cond.add ("categories.right <= (SELECT right FROM categories as c WHERE c.id = " + category.out + ")")

				-- Filter by city
			if city /= 0 then
				cond ["projects.city_id"].equals (city)
			end
			query := a_query
		end

	search_text: STRING

	city: INTEGER_64

	category: INTEGER_64

feature {WSF_PAGE_CONTROL, WSF_CONTROL} -- State management

	state: WSF_JSON_OBJECT
			-- Return state which contains the search_text
		do
			Result := Precursor
			Result.put_string (search_text, "search_text")
			Result.put_integer (city, "city")
			Result.put_integer (category, "category")
		end

	set_state (new_state: JSON_OBJECT)
			-- Restore search_text from json
		do
			Precursor (new_state)
			if attached {JSON_STRING} new_state.item ("search_text") as new_search_text then
				search_text := new_search_text.item
			end
			if attached {JSON_NUMBER} new_state.item ("city") as new_city then
				city := new_city.item.to_integer_64
			end
			if attached {JSON_NUMBER} new_state.item ("category") as new_category then
				category := new_category.item.to_integer_64
			end
		end

feature -- Change

end
