class_name AggregateSearchDataSource
extends DataSource

func _init():
	type = TYPES.AGGREGATE_SEARCH
	
func make_query(dashboard_filters : Dictionary, attr : Dictionary):
	var q : String = query
	
	if dashboard_filters["cloud"] != "" and dashboard_filters["cloud"] != "All":
		q += " and /ancestors.cloud.reported.name=\"%s\"" % dashboard_filters["cloud"]
	if dashboard_filters["region"] != "" and dashboard_filters["region"] != "All":
		q += " and /ancestors.region.reported.name=\"%s\"" % dashboard_filters["region"]
	if dashboard_filters["account"] != "" and dashboard_filters["account"] != "All":
		q += " and /ancestors.account.reported.name=\"%s\"" % dashboard_filters["account"]
		
		
	API.aggregate_search(q, self)
	
func _on_aggregate_search_done(_error : int, response):
	if not response.transformed.result is Array or response.transformed.result.size() == 0:
		_g.emit_signal("add_toast", "Invalid Aggregate Search", "There is a problem with the aggregate search query.", 1, self)
		return
	if widget is TableWidget:
		widget.header_columns_count = response.transformed.result[0]["group"].size()
		print(widget.header_columns_count)
	widget.set_data(response.transformed.result, type)

	
func copy_data_source(other : AggregateSearchDataSource):
	query = other.query
	
