extends BaseWidget

export (float) var x_origin := 0.0 setget set_x_origin
export (float) var x_range := 200.0 setget set_x_range
export (bool) var auto_x := true
export (float) var max_y_value := 100.0
export (float) var min_y_value := 0.0
export (bool) var x_axis_date := true
export (bool) var auto_scale := true
export (Vector2) var divisions := Vector2(3.0, 3.0)

export (Array, PoolVector2Array) var series : Array

var dynamic_label_scene := preload("res://components/widgets/DynamicLabel.tscn")
var series_scene := preload("res://components/widgets/Serie.tscn")
var mouse_on_graph := false

var step := 1
var prev_origin : Vector2

var colors := [
	Color.aquamarine,
	Color.indianred,
	Color.dodgerblue,
	Color.khaki,
	Color.orchid,
	Color.slateblue
]

var current_color := 0

onready var graph_area := $Viewport/GridContainer/Grid/GraphArea
onready var legend := $CanvasLayer/PopupLegend
onready var legend_container := $CanvasLayer/PopupLegend/VBoxContainer
onready var x_labels := $Viewport/GridContainer/XLabels
onready var y_labels := $Viewport/GridContainer/YLabels
onready var grid := $Viewport/GridContainer/Grid

func _ready() -> void:
	legend.visible = false
	if get_parent().get_parent() is WidgetContainer:
		get_parent().get_parent().connect("moved_or_resized", self, "_on_Grid_resized")
	_on_Grid_resized()

func _input(event) -> void:
#	if event.is_action_pressed("ui_accept"):
#		var data : PoolVector2Array = []
#		data.resize(100)
#
#		for i in data.size():
#			data[i] = Vector2(i,2)
#
#		clear_series()
#		add_serie(data, null, "", true)
#
#		for i in data.size():
#			data[i] = Vector2(i+20,1+int(i/10))
#		add_serie(data, null, "", true)
#
#		for i in data.size():
#			data[i] = Vector2(i,int(i/5))
#		add_serie(data, null, "", true)
#
#		complete_update()

	if event is InputEventMouseMotion and mouse_on_graph and series.size() > 0:
		var x = x_range * $Grid/LegendPosition.get_local_mouse_position().x / graph_area.rect_size.x
		legend.rect_global_position = get_global_mouse_position()
		legend.rect_size.y = 0
			
		var stacked = 0
		
		for label in legend_container.get_children():
			legend_container.remove_child(label)
			label.queue_free()
		
		for i in series.size():
			var index = series.size() - i - 1
			var l := Label.new()
			var line : Line2D = graph_area.get_child(index)
			var closest_point = find_value_at_x(x, series[index])
			
			l.text = line.name + ": " + str(closest_point.y)
			l.set_meta("value", closest_point.y)
			l.set("custom_colors/font_color", line.default_color)
			
			legend_container.add_child(l)
			if line.get_meta("stack"):
				closest_point.y += stacked
				stacked = closest_point.y
			line.show_indicator(transform_point(closest_point))
		
		# Sort labels
		for i in legend_container.get_child_count():
			for j in range(i+1, legend_container.get_child_count()):
				if legend_container.get_child(i).get_meta("value") < legend_container.get_child(j).get_meta("value"):
					var label = legend_container.get_child(i)
					legend_container.move_child(legend_container.get_child(j), i)
					legend_container.move_child(label, j)

func set_x_origin(origin : float) -> void:
	x_origin = origin
	
func set_x_range(r : float) -> void:
	x_range = r

func _on_Grid_resized() -> void:
	if not is_instance_valid(x_labels):
		return

	yield(VisualServer,"frame_post_draw")
	$Viewport.size = rect_size
	$Viewport/GridContainer.rect_size = rect_size
	
	complete_update()
	var n = x_labels.get_child_count()
	if n > 0:
		x_labels.get_child(0).rect_min_size.x = grid.rect_size.x / divisions.x / 2
		x_labels.get_child(n - 1).rect_min_size.x = grid.rect_size.x / divisions.x / 2
	
	grid.material.set_shader_param("grid_divisions", divisions)
	grid.material.set_shader_param("size", grid.rect_size)
	
func update_series() -> void:
	if not is_instance_valid(graph_area):
		return
	if graph_area.rect_size.x == 0 or graph_area.rect_size.y == 0:
		return
	if series.size() == 0:
		return
	var origin : Vector2 = Vector2(grid.rect_global_position.x, grid.rect_global_position.y + graph_area.rect_size.y)
	var n = graph_area.get_child_count()
	var stacked : PoolRealArray = []
	stacked.resize(range(0, x_range, step).size())
	stacked.fill(0)
	for i in n:
		var index = n - i - 1
		var line : Line2D = graph_area.get_child(index)
		var values : PoolVector2Array = []
		
		for j in stacked.size():
			var point = find_value_at_x(j * step ,series[index])
			if line.get_meta("stack"):
				point.y += stacked[j]
				stacked[j] = point.y
#			if graph_area.get_global_rect().grow(1).has_point(point + origin):
			values.append(transform_point(point))
		line.points = values
		line.global_position = origin


func update_graph_area(force := false) -> void:
	if not is_instance_valid(graph_area):
		return
	var new_divisions = (graph_area.rect_size / 100).snapped(Vector2.ONE)
	new_divisions.x = max(2, new_divisions.x)
	new_divisions.y = max(2, new_divisions.y)

	
	if divisions.x != new_divisions.x or force:
		divisions.x = new_divisions.x
		var nx = divisions.x
	
		for l in x_labels.get_children():
			x_labels.remove_child(l)
			l.queue_free()
			
		
		var dummy_label := Control.new()
		dummy_label.rect_min_size.x = x_labels.rect_size.x / nx / 2
		x_labels.add_child(dummy_label)
		
		for i in nx - 1:
			var l : DynamicLabel = dynamic_label_scene.instance()
			var x_value = int(x_origin + (i+1)*x_range / nx)
			if x_axis_date:
				x_value = Time.get_datetime_string_from_unix_time(x_value).replace("T", "\n")
			l.max_font_size = 18
			l.min_font_size = 12
			l.text = str(x_value)
			l.size_flags_horizontal = SIZE_EXPAND_FILL
			l.size_flags_vertical = 0
			l.valign = Label.VALIGN_TOP
			l.align = Label.ALIGN_CENTER
			x_labels.add_child(l)

		x_labels.add_child(dummy_label.duplicate())
		
	if divisions.y != new_divisions.y or force:
		divisions.y = new_divisions.y
		var ny = divisions.y
		for l in y_labels.get_children():
			l.queue_free()
			
		for i in ny:
			var l = dynamic_label_scene.instance()
			l.max_font_size = 14
			l.min_font_size = 10
			l.text = str(int(max_y_value - (i+1)*(max_y_value - min_y_value) / ny))
			l.size_flags_vertical = SIZE_EXPAND_FILL
			l.align = Label.ALIGN_RIGHT
			l.valign = Label.VALIGN_BOTTOM
			y_labels.add_child(l)
		
func add_serie(data : PoolVector2Array, color = null, serie_name := "", stack := false) -> void:
	var serie := series_scene.instance()
	serie.set_meta("stack", stack)
	serie.get_node("Polygon2D").visible = stack
	graph_area.add_child(serie)
	serie.points = data
	series.append(data)
	
	if color != null:
		serie.default_color = color
	else:
		serie.default_color = colors[current_color]
		current_color = wrapi(current_color + 1, 0, colors.size())
		
	if serie_name == "":
		serie_name = "Serie %d" % series.size()
		
	serie.name = serie_name
	
	
func clear_series() -> void:
	for serie in graph_area.get_children():
		if serie is Line2D:
			graph_area.remove_child(serie)
			serie.queue_free()
	current_color = 0
	series.clear()

func set_scale_from_series() -> void:
	if series.size() == 0:
		return
	
	var maxy = -INF
	var miny = INF

	var stacked : PoolRealArray = []
	stacked.resize(range(0, x_range, step).size())
	stacked.fill(0)

	for j in stacked.size():
		for serie in series:
			var value = find_value_at_x(j*step, serie)
			if miny > value.y:
				miny = value.y
			if stacked:
				value.y += stacked[j]
				stacked[j] = value.y
			if maxy < value.y:
				maxy = value.y
			
	
	max_y_value = maxy + (maxy - miny) * 0.1
	min_y_value = miny - (maxy - miny) * 0.1
	if miny == 0:
		min_y_value = 0
	
	
func _process(_delta : float) -> void:
	var origin : Vector2 = graph_area.rect_global_position + Vector2(0, graph_area.rect_size.y)
	
	if prev_origin != origin:
		prev_origin = origin
		for line in graph_area.get_children():
			if line is Line2D:
				line.global_position = origin


func complete_update(force_update_graph_area := false) -> void:
	if auto_scale:
		set_scale_from_series()
	update_series()
	update_graph_area(force_update_graph_area)
	
	
func find_closest_at_x(target_x : float, serie : PoolVector2Array) -> Vector2:
	var distance = INF
	var result = null
	
	for value in serie:
		var new_distance = abs(value.x - target_x)
		if new_distance > distance:
			break
		distance = new_distance
		result = value
		
	return result
	
func find_value_at_x(target_x : float, serie : PoolVector2Array) -> Vector2:
	var prev = null
	var next = null
	for value in serie:
		if value.x == target_x:
			return value
		elif value.x < target_x:
			prev = value
		else:
			next = value
			break
			
	if prev == null or next == null:
		return Vector2(target_x, 0)
	else:
		return Vector2(target_x, lerp(prev.y, next.y ,(target_x - prev.x) / (next.x - prev.x)))

func _on_Grid_mouse_entered() -> void:
	for line in graph_area.get_children():
		line.indicator.visible = true
	mouse_on_graph = true
	yield(VisualServer,"frame_post_draw")
	legend.visible = true


func _on_Grid_mouse_exited() -> void:
	for line in graph_area.get_children():
		line.indicator.visible = false
	legend.visible = false
	mouse_on_graph = false

func transform_point(point : Vector2) -> Vector2:
	var ratio := Vector2(x_range / graph_area.rect_size.x,(max_y_value - min_y_value) / graph_area.rect_size.y)
	point += Vector2(0, -min_y_value)
	point /= ratio
	point.y *= -1
	if point.y >= 0.0:
		point.y = -0.0001
		
	return point

func get_csv(separator := ",", end_of_line := "\n") -> String:
	if series.size() <= 0:
		return ""
		
	var data : PoolStringArray = []
	var header : PoolStringArray = ["Date"]
	
	for line in graph_area.get_children():
		header.append(line.name)
		
	data.append(header.join(separator))
	
	for i in series[0].size():
		var row : PoolStringArray = []
		row.append(Time.get_datetime_string_from_unix_time(series[0][i].x + x_origin))
		for serie in series:
			row.append(serie[i].y)
			
		data.append(row.join(separator))
	
	return data.join(end_of_line)
			
