extends Control


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _quit():
	get_tree().quit(0)
