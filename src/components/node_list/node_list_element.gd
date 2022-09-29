extends MarginContainer

const NODE_LIMIT:int = 500

var active_request:ResotoAPI.Request
var parent_node_id:String
var parent_node_name:String
var filter_variables:Dictionary

onready var parent_button = find_node("ParentNodeButton")
onready var kind_label = find_node("KindNameLabel")
onready var kind_arrow = find_node("KindLabelArrow")
onready var template = find_node("ResultTemplate")
onready var scroll_container = $Margin/VBox/MainPanel/ScrollContainer/Content
onready var vbox = $Margin/VBox/MainPanel/ScrollContainer/Content/ListContainer


func show_kind_from_node_data(parent_node:Dictionary, kind:String):
	var search_command = "id(" + parent_node.id + ") -[1:]-> is(" + kind + ") limit " + str(NODE_LIMIT)
	
	parent_node_id = parent_node.id
	parent_node_name = parent_node.reported.name
	
	parent_button.text = parent_node_name
	parent_button.set_meta("id", parent_node_id)
	parent_button.show()
	kind_label.text = kind
	
	print(search_command)
	active_request = API.graph_search(search_command, self, "list")


func show_kind_from_node_id(id:String, kind:String):
	var search_command = "id(" + id + ") -[1:]-> is(" + kind + ") limit " + str(NODE_LIMIT)
	parent_node_id = id
	
	parent_button.text = parent_node_id
	parent_button.set_meta("id", parent_node_id)
	parent_button.show()
	kind_label.text = kind
	
	active_request = API.graph_search(search_command, self, "list")


func show_list_from_search(parent_node:Dictionary, search_command:String, kind_label_text:String):
	parent_node_id = parent_node.id
	parent_node_name = parent_node.reported.name
	
	parent_button.text = parent_node_name
	parent_button.set_meta("id", parent_node_id)
	parent_button.show()
	kind_label.text = kind_label_text
	
	print(search_command)
	active_request = API.graph_search(search_command, self, "list")


func _on_graph_search_done(error:int, _response:UserAgent.Response) -> void:
	if error:
		_g.emit_signal("add_toast", "Error in Node List", Utils.err_enum_to_string(error) + "\nBody: "+ active_request.body, 1, self)
		return
	
	if _response.transformed.has("result"):
		# Delete old results, prepare new container (fastest way to delete a lot of nodes)
		reset_display()
		
		filter_variables = {}
		var current_result = _response.transformed.result
		for r in current_result:
			add_result_element(r, vbox)


func add_result_element(r, parent_element:Node):
	var filter_string = ""
	
	var new_result = template.duplicate()
	parent_element.add_child(new_result)
	new_result.connect("pressed", self, "_on_node_button_pressed", [r.id])
	new_result.name = r.id
	new_result.hint_tooltip = "id: " + r.id
	var ancestors:String = ""
	if r.has("ancestors"):
		if r.ancestors.has("cloud"):
			ancestors += r.ancestors.cloud.reported.name
		if r.ancestors.has("account"):
			var r_account = r.ancestors.account.reported.name
			r_account = Utils.truncate_string_px(r_account, 4, 150.0)
			ancestors += " > " + r_account
		if r.ancestors.has("region"):
			ancestors += " > " + r.ancestors.region.reported.name
		if r.ancestors.has("zone"):
			ancestors += " > " + r.ancestors.zone.reported.name
			
	filter_string += ancestors
	filter_string += r.id + r.reported.name + r.reported.kind
	
	var r_name = r.reported.name
	var r_kind = r.reported.kind
	
	filter_variables[r.id] = filter_string
	
	new_result.get_node("Result/ResultName").text = "[" + r_kind + "] :: " + r_name
	new_result.get_node("Result/ResultDetails").text = ancestors


func filter_results(filter_string:String):
	if filter_string == "":
		for c in vbox.get_children():
			c.show()
		return
	
	for c in vbox.get_children():
		c.visible = filter_variables[c.name].find(filter_string) >= 0


func _on_ParentNodeButton_pressed():
	reset_display()
	_g.content_manager.change_section("node_single_info")
	_g.content_manager.find_node("NodeSingleInfo").show_node(parent_node_id)


func _on_node_button_pressed(id:String):
	reset_display()
	_g.content_manager.change_section("node_single_info")
	_g.content_manager.find_node("NodeSingleInfo").show_node(id)


func reset_display():
	vbox.queue_free()
	vbox = VBoxContainer.new()
	scroll_container.add_child(vbox)
	$Margin/VBox/Filter/FilterLineEdit.text = ""


func _on_FullTextSearch_text_changed(new_text):
	filter_results(new_text)