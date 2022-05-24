extends Node

signal add_toast

var popup_manager: CanvasLayer = null
var ui_shrink: float = 1.0 setget set_ui_shrink

const TERMINAL_COLORS: Array = [
	Color(0,0,0,1),
	Color(128,0,0,1),
	Color(0,128,0,1),
	Color(128,128,0,1),
	Color(0,0,128,1),
	Color(128,0,128,1),
	Color(0,128,128,1),
	Color(192,192,192,1),
	Color(128,128,128,1),
	Color(255,0,0,1),
	Color(0,255,0,1),
	Color(255,255,0,1),
	Color(0,0,255,1),
	Color(255,0,255,1),
	Color(0,255,255,1),
	Color(255,255,255,1),
	Color(0,0,0,1),
	Color(0,0,95,1),
	Color(0,0,135,1),
	Color(0,0,175,1),
	Color(0,0,215,1),
	Color(0,0,255,1),
	Color(0,95,0,1),
	Color(0,95,95,1),
	Color(0,95,135,1),
	Color(0,95,175,1),
	Color(0,95,215,1),
	Color(0,95,255,1),
	Color(0,135,0,1),
	Color(0,135,95,1),
	Color(0,135,135,1),
	Color(0,135,175,1),
	Color(0,135,215,1),
	Color(0,135,255,1),
	Color(0,175,0,1),
	Color(0,175,95,1),
	Color(0,175,135,1),
	Color(0,175,175,1),
	Color(0,175,215,1),
	Color(0,175,255,1),
	Color(0,215,0,1),
	Color(0,215,95,1),
	Color(0,215,135,1),
	Color(0,215,175,1),
	Color(0,215,215,1),
	Color(0,215,255,1),
	Color(0,255,0,1),
	Color(0,255,95,1),
	Color(0,255,135,1),
	Color(0,255,175,1),
	Color(0,255,215,1),
	Color(0,255,255,1),
	Color(95,0,0,1),
	Color(95,0,95,1),
	Color(95,0,135,1),
	Color(95,0,175,1),
	Color(95,0,215,1),
	Color(95,0,255,1),
	Color(95,95,0,1),
	Color(95,95,95,1),
	Color(95,95,135,1),
	Color(95,95,175,1),
	Color(95,95,215,1),
	Color(95,95,255,1),
	Color(95,135,0,1),
	Color(95,135,95,1),
	Color(95,135,135,1),
	Color(95,135,175,1),
	Color(95,135,215,1),
	Color(95,135,255,1),
	Color(95,175,0,1),
	Color(95,175,95,1),
	Color(95,175,135,1),
	Color(95,175,175,1),
	Color(95,175,215,1),
	Color(95,175,255,1),
	Color(95,215,0,1),
	Color(95,215,95,1),
	Color(95,215,135,1),
	Color(95,215,175,1),
	Color(95,215,215,1),
	Color(95,215,255,1),
	Color(95,255,0,1),
	Color(95,255,95,1),
	Color(95,255,135,1),
	Color(95,255,175,1),
	Color(95,255,215,1),
	Color(95,255,255,1),
	Color(135,0,0,1),
	Color(135,0,95,1),
	Color(135,0,135,1),
	Color(135,0,175,1),
	Color(135,0,215,1),
	Color(135,0,255,1),
	Color(135,95,0,1),
	Color(135,95,95,1),
	Color(135,95,135,1),
	Color(135,95,175,1),
	Color(135,95,215,1),
	Color(135,95,255,1),
	Color(135,135,0,1),
	Color(135,135,95,1),
	Color(135,135,135,1),
	Color(135,135,175,1),
	Color(135,135,215,1),
	Color(135,135,255,1),
	Color(135,175,0,1),
	Color(135,175,95,1),
	Color(135,175,135,1),
	Color(135,175,175,1),
	Color(135,175,215,1),
	Color(135,175,255,1),
	Color(135,215,0,1),
	Color(135,215,95,1),
	Color(135,215,135,1),
	Color(135,215,175,1),
	Color(135,215,215,1),
	Color(135,215,255,1),
	Color(135,255,0,1),
	Color(135,255,95,1),
	Color(135,255,135,1),
	Color(135,255,175,1),
	Color(135,255,215,1),
	Color(135,255,255,1),
	Color(175,0,0,1),
	Color(175,0,95,1),
	Color(175,0,135,1),
	Color(175,0,175,1),
	Color(175,0,215,1),
	Color(175,0,255,1),
	Color(175,95,0,1),
	Color(175,95,95,1),
	Color(175,95,135,1),
	Color(175,95,175,1),
	Color(175,95,215,1),
	Color(175,95,255,1),
	Color(175,135,0,1),
	Color(175,135,95,1),
	Color(175,135,135,1),
	Color(175,135,175,1),
	Color(175,135,215,1),
	Color(175,135,255,1),
	Color(175,175,0,1),
	Color(175,175,95,1),
	Color(175,175,135,1),
	Color(175,175,175,1),
	Color(175,175,215,1),
	Color(175,175,255,1),
	Color(175,215,0,1),
	Color(175,215,95,1),
	Color(175,215,135,1),
	Color(175,215,175,1),
	Color(175,215,215,1),
	Color(175,215,255,1),
	Color(175,255,0,1),
	Color(175,255,95,1),
	Color(175,255,135,1),
	Color(175,255,175,1),
	Color(175,255,215,1),
	Color(175,255,255,1),
	Color(215,0,0,1),
	Color(215,0,95,1),
	Color(215,0,135,1),
	Color(215,0,175,1),
	Color(215,0,215,1),
	Color(215,0,255,1),
	Color(215,95,0,1),
	Color(215,95,95,1),
	Color(215,95,135,1),
	Color(215,95,175,1),
	Color(215,95,215,1),
	Color(215,95,255,1),
	Color(215,135,0,1),
	Color(215,135,95,1),
	Color(215,135,135,1),
	Color(215,135,175,1),
	Color(215,135,215,1),
	Color(215,135,255,1),
	Color(215,175,0,1),
	Color(215,175,95,1),
	Color(215,175,135,1),
	Color(215,175,175,1),
	Color(215,175,215,1),
	Color(215,175,255,1),
	Color(215,215,0,1),
	Color(215,215,95,1),
	Color(215,215,135,1),
	Color(215,215,175,1),
	Color(215,215,215,1),
	Color(215,215,255,1),
	Color(215,255,0,1),
	Color(215,255,95,1),
	Color(215,255,135,1),
	Color(215,255,175,1),
	Color(215,255,215,1),
	Color(215,255,255,1),
	Color(255,0,0,1),
	Color(255,0,95,1),
	Color(255,0,135,1),
	Color(255,0,175,1),
	Color(255,0,215,1),
	Color(255,0,255,1),
	Color(255,95,0,1),
	Color(255,95,95,1),
	Color(255,95,135,1),
	Color(255,95,175,1),
	Color(255,95,215,1),
	Color(255,95,255,1),
	Color(255,135,0,1),
	Color(255,135,95,1),
	Color(255,135,135,1),
	Color(255,135,175,1),
	Color(255,135,215,1),
	Color(255,135,255,1),
	Color(255,175,0,1),
	Color(255,175,95,1),
	Color(255,175,135,1),
	Color(255,175,175,1),
	Color(255,175,215,1),
	Color(255,175,255,1),
	Color(255,215,0,1),
	Color(255,215,95,1),
	Color(255,215,135,1),
	Color(255,215,175,1),
	Color(255,215,215,1),
	Color(255,215,255,1),
	Color(255,255,0,1),
	Color(255,255,95,1),
	Color(255,255,135,1),
	Color(255,255,175,1),
	Color(255,255,215,1),
	Color(255,255,255,1),
	Color(8,8,8,1),
	Color(18,18,18,1),
	Color(28,28,28,1),
	Color(38,38,38,1),
	Color(48,48,48,1),
	Color(58,58,58,1),
	Color(68,68,68,1),
	Color(78,78,78,1),
	Color(88,88,88,1),
	Color(98,98,98,1),
	Color(108,108,108,1),
	Color(118,118,118,1),
	Color(128,128,128,1),
	Color(138,138,138,1),
	Color(148,148,148,1),
	Color(158,158,158,1),
	Color(168,168,168,1),
	Color(178,178,178,1),
	Color(188,188,188,1),
	Color(198,198,198,1),
	Color(208,208,208,1),
	Color(218,218,218,1),
	Color(228,228,228,1),
	Color(238,238,238,1)
]


func set_ui_shrink(new_shrink:float) -> void:
	ui_shrink = new_shrink
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,  SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1920,1080), ui_shrink)
