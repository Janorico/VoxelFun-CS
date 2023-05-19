extends Control


const MAIN_SCENE: PackedScene = preload("res://scenes/game/main.tscn")
const WORLDS_DIR: String = "user://worlds/"
onready var worlds_list: ItemList = $MarginContainer/Page1/WorldsList
onready var message_label: Label = $Message/Label
onready var new_world_name: LineEdit = $NewWorldDialog/NameLineEdit
onready var delete_confirmation: ConfirmationDialog = $DeleteConfirmation
onready var animation_player: AnimationPlayer = $AnimationPlayer
export var map_icon: Texture = preload("res://assets/icons/icons8-world-map-96.png")
var worlds: Array = []
var delete_idx


func _ready():
	if OS.is_debug_build():
		OS.window_fullscreen = false
		OS.window_size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
		OS.center_window()
	load_worlds()


func load_worlds():
	var dir = get_dir()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	worlds_list.clear()
	while not file_name == "":
		if not dir.current_is_dir():
			worlds.append(file_name)
			worlds_list.add_item(file_name, map_icon)
		file_name = dir.get_next()


func get_dir() -> Directory:
	var dir = Directory.new()
	if not dir.dir_exists(WORLDS_DIR):
		if not dir.make_dir(WORLDS_DIR) == OK:
			OS.crash("Can't create worlds dir!")
		# Copy world file from older versions
		if dir.file_exists("user://world"):
			if not dir.copy("user://world", "%sdefault" % WORLDS_DIR) == OK:
				OS.alert("Can't copy old world!")
	dir.open(WORLDS_DIR)
	return dir


func open_world(world: String):
	var main = MAIN_SCENE.instance()
	main.get_node("Game").initial_world_path = get_world_path(world)
	get_parent().add_child(main)
	queue_free()
	get_tree().current_scene = main


func get_world_path(world: String) -> String:
	return "%s%s" % [WORLDS_DIR, world]


func show_message(msg: String):
	message_label.text = msg
	animation_player.play("message")


func _on_new_world_dialog_confirmed():
	var wname = new_world_name.text
	if wname == "":
		show_message("Name is empty!")
	else:
		open_world(wname)


func _on_open_button_pressed():
	var selected_items = worlds_list.get_selected_items()
	if selected_items.size() > 0:
		open_world(worlds[selected_items[0]])
	else:
		show_message("No selection!")


func _on_delete_button_pressed():
	var selected_items = worlds_list.get_selected_items()
	if selected_items.size() > 0:
		delete_idx = selected_items[0]
		delete_confirmation.popup_centered()
	else:
		show_message("No selection!")


func _on_delete_confirmation_confirmed():
	var dir = get_dir()
	show_message("Action finished with code %s." % dir.remove(worlds[delete_idx]))
	delete_idx = null
	load_worlds()


func _quit():
	get_tree().quit(0)
