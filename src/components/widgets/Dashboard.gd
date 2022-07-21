extends Control

onready var widgets : Control = $Widgets
onready var grid_background : ColorRect = $Grid

export var x_grid_ratio := 10.0 
export var y_grid_size := 100.0 
export var grid_margin := Vector2(5,5)

onready var _x_grid_size := rect_size.x / x_grid_ratio
onready var widget_container_scene := preload("res://components/widgets/WidgetContainer.tscn")

var ts_start : int
var ts_end : int
var step : int

func add_widget(widget_data : Dictionary) -> void:
	var grid_size : Vector2 = Vector2(_x_grid_size, y_grid_size)
	var container = widget_container_scene.instance()
	container.name = "WidgetContainer"
	container.dashboard = self
	widgets.call_deferred("add_child", container)
	container.grid_size = grid_size
	container.rect_size = 2*grid_size
	var empty_slot = find_empty_slot(container.get_rect())
	container.rect_position = empty_slot.snapped(grid_size) 
	var reference = ReferenceRect.new()
	container.parent_reference = reference
	$References.add_child(reference)
	
	container.connect("moved_or_resized", self, "_on_widget_moved_or_resized")
	
	var widget = widget_data["scene"]
	container.data_sources = widget_data["data_sources"]
	container.set_deferred("widget_title", widget_data["title"])
	container.call_deferred("add_widget", widget)
	
	container.connect("config_pressed", owner, "_on_WidgetContainer_config_pressed")
	
	yield(VisualServer,"frame_post_draw")
	
	reference.rect_global_position = container.rect_global_position
	reference.rect_size = container.rect_size
	
	reference.mouse_filter = MOUSE_FILTER_IGNORE
	reference.border_color = Color(0.662745, 0.568627, 0.792157)
	reference.editor_only = false
	reference.visible = false
	
	container.set_anchors()
	
func lock(locked : bool) -> void:
	grid_background.visible = !locked
	
	for widget in widgets.get_children():
		widget.lock(locked)

func _on_Grid_resized() -> void:
	_x_grid_size = rect_size.x / x_grid_ratio

	var grid_size := Vector2(_x_grid_size, y_grid_size)
	
	$Grid.material.set_shader_param("grid_size", grid_size)
	$Grid.material.set_shader_param("dashboard_size", rect_size)
	for widget in $Widgets.get_children():
		widget.grid_size.x = _x_grid_size
		
	yield(VisualServer, "frame_post_draw")
	for widget in $Widgets.get_children():
		widget.parent_reference.set_deferred("rect_global_position" , widget.rect_global_position)
		widget.parent_reference.set_deferred("rect_size", widget.rect_size)

func find_rect_intersection(rect : Rect2, exclude_widgets := []):
	var all_widgets : Array = widgets.get_children()

	for widget in all_widgets:
		if widget in exclude_widgets:
			continue
		var other_rect : Rect2 = widget.parent_reference.get_rect()

		if other_rect.intersects(rect):
			return other_rect
	return null

func find_empty_slot(rect : Rect2) -> Vector2:
	var position = null
	var j : int = 0
	rect = rect.grow_individual(-1,-1,-1,-1)
	while true:
		for i in (x_grid_ratio):
			rect.position = Vector2(i * _x_grid_size, j * y_grid_size)
			if rect.position.x + rect.size.x > rect_size.x:
				continue
			if find_rect_intersection(rect) == null:
				position = rect.position
				break
		if position != null:
			break
		j += 1
	return position


func refresh(from : int, to : int, interval : int) -> void:
	ts_start = from
	ts_end = to
	step = interval
	for widget in widgets.get_children():
		widget.execute_query()
	
func _on_widget_moved_or_resized():
	var max_y : float = -INF
	for widget in widgets.get_children():
		if widget.rect_size.y + widget.rect_position.y > max_y:
			max_y = widget.rect_size.y + widget.rect_position.y
			
	rect_min_size.y = max(max_y, get_parent().rect_size.y)