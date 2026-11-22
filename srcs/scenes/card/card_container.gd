extends CanvasLayer

@onready var hbox := $CardContainer/HBoxContainer2/HBoxContainer
@onready var input_blocker := $InputBlocker

var is_visible := false


func _ready() -> void:
	hbox.visible = is_visible
	input_blocker.visible = is_visible

func _on_show_pressed() -> void:
	is_visible = !is_visible
	$CardContainer/HBoxContainer2/Show.text = "HIDE" if is_visible else "SHOW"
	hbox.visible = is_visible
	input_blocker.visible = is_visible
