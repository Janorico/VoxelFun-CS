extends ColorRect


export var player_path: NodePath
onready var player: Player = get_node(player_path)
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
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


func _quit():
	get_tree().quit(0)
