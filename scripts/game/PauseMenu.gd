extends ColorRect


export var player_path: NodePath
onready var player: Player = get_node(player_path)
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()


func _process(_delta):
	if Input.is_action_just_released("pause"):
		if visible:
			resume()
		else:
			pause()


func pause():
	animation_player.play("show")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.paused = true


func resume():
	animation_player.play("hide")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.paused = false


func _main_menu():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/startup.tscn")


func _quit():
	get_tree().quit(0)


func _on_rich_text_label_meta_clicked(meta):
	# warning-ignore:return_value_discarded
	OS.shell_open(meta)
