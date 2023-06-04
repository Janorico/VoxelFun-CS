class_name Player
extends KinematicBody

onready var stair_detector: RayCast = $StairDetector
onready var camera = $CameraBase/Camera
onready var camera_base = $CameraBase
onready var raycast = $CameraBase/Camera/RayCast
onready var info_label = $CameraBase/Camera/InfoLabel
onready var selected_block_preview: TextureRect = $CameraBase/Camera/SelectedBlockPreview
onready var selected_block_name: Label = $CameraBase/Camera/SelectedBlockPreview/NameLabel
onready var block_dialog: PopupPanel = $CameraBase/Camera/BlockPopup
onready var blocks_list: ItemList = $CameraBase/Camera/BlockPopup/List
onready var headlamp: SpotLight = $CameraBase/Camera/Headlamp
# Reset values
onready var initial_position: Vector3 = translation
onready var initial_rotation: Vector3 = rotation_degrees

var Chunk = load("res://scripts/game/Chunk.gd")
var selected_block = 0
export var blocks_texture: AtlasTexture

var camera_x_rotation = 0

const mouse_sensitivity = 0.3
const SPEED = 5
var velocity = Vector3.ZERO
const gravity = 9.8
var jump_vel = 5
var fly: bool = false

var paused = false

signal place_block(pos, norm, type)
signal destroy_block(pos, norm, collider)
signal highlight_block(pos, norm)
signal unhighlight_block()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_block_preview()
	# Setup blocks list
	blocks_list.clear()
	var idx = 0
	for block_name in Chunk.block_types:
		var block = Chunk.block_types[block_name]
		var preview = blocks_texture.duplicate()
		if block.has(Chunk.Side.left):
			preview.region.position = block[Chunk.Side.left] * 16
		elif block.has(Chunk.Side.only):
			preview.region.position = block[Chunk.Side.only] * 16
		else:
			preview.region.position = Vector2(-16, -16)
		blocks_list.add_item(block_name, preview)
		if block["Tags"].has(Chunk.Tags.Dont_List):
			blocks_list.set_item_disabled(idx, true)
		idx += 1
	for block_name in Chunk.extra_blocks:
		blocks_list.add_item(block_name, Chunk.extra_blocks[block_name]["Preview"])


func _input(event):
	# Mouse movement
	if not paused:
		if event is InputEventMouseMotion:
			self.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			
			var x_delta = event.relative.y * mouse_sensitivity
			if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90:
				camera.rotate_x(deg2rad(-x_delta))
				camera_x_rotation += x_delta


func _physics_process(delta):
	var cx = floor(self.translation.x / Chunk.DIMENSION.x)
	var cz = floor(self.translation.z / Chunk.DIMENSION.z)
	var px = self.translation.x - cx * Chunk.DIMENSION.x
	var py = self.translation.y
	var pz = self.translation.z - cz * Chunk.DIMENSION.z
	info_label.text = "Chunk (%d, %d) pos (%d, %d, %d)" % [cx, cz, px, py, pz]
	if not paused:
		# Check the raycast
		if raycast.is_colliding():
			var pos = raycast.get_collision_point()
			var norm = raycast.get_collision_normal()
			emit_signal("highlight_block", pos, norm)
			if Input.is_action_just_pressed("click"):
				print("Click")
				emit_signal("destroy_block", pos, norm, raycast.get_collider())
			elif Input.is_action_just_pressed("right_click"):
				emit_signal("place_block", pos, norm, selected_block)
		else:
			emit_signal("unhighlight_block")
		
		if Input.is_action_just_released("open_block_dialog"):
			block_dialog.popup_centered()
		
		var power_multipler = (Input.get_action_strength("run") + 1)
		if Input.is_action_just_pressed("jump") and is_on_floor() and not fly:
			velocity.y = jump_vel * power_multipler
		else:
			var camera_base_basis = self.get_global_transform().basis
			
			var direction = Vector3()
			
			if Input.is_action_pressed("forward"):
				direction -= camera_base_basis.z #forward is negative in Godot
				if stair_detector.is_colliding() and is_on_floor() and not fly:
					velocity.y = jump_vel * power_multipler
			if Input.is_action_pressed("backward"):
				direction += camera_base_basis.z
			
			# Strafe
			if Input.is_action_pressed("left"):
				direction -= camera_base_basis.x
			if Input.is_action_pressed("right"):
				direction += camera_base_basis.x
			
			# Process inputs (only in the xz plane)
			var speed_input = SPEED * power_multipler
			velocity.x = direction.x * speed_input
			velocity.z = direction.z * speed_input
		if fly:
			velocity.y = move_toward(velocity.y, Input.get_axis("sink", "jump") * jump_vel, delta * 10)
		else:
			velocity.y -= gravity * delta
		velocity = move_and_slide(velocity, Vector3.UP)
		if Input.is_action_just_released("reset_player"):
			translation = initial_position
			rotation_degrees = initial_rotation
			velocity = Vector3.ZERO
		if Input.is_action_just_released("toggle_fly"):
			fly = not fly
		if Input.is_action_just_released("headlamp"):
			match headlamp.light_energy:
				0.0: headlamp.light_energy = 1.0
				1.0: headlamp.light_energy = 2.0
				2.0: headlamp.light_energy = 0.0


func update_block_preview():
	if selected_block < Chunk.block_types.size():
		var block_name = Chunk.block_types.keys()[selected_block]
		var block = Chunk.block_types[block_name]
		selected_block_preview.texture = blocks_texture
		selected_block_name.text = block_name
		if block.has(Chunk.Side.left):
			blocks_texture.region.position = block[Chunk.Side.left] * 16
		elif block.has(Chunk.Side.only):
			blocks_texture.region.position = block[Chunk.Side.only] * 16
		else:
			blocks_texture.region.position = Vector2(-16, -16)
	else:
		var block_name = Chunk.extra_blocks.keys()[selected_block - Chunk.block_types.size()]
		var block = Chunk.extra_blocks[block_name]
		selected_block_preview.texture = block["Preview"]
		selected_block_name.text = block_name


func _on_block_popup_about_to_show():
	paused = true
	blocks_list.select(selected_block)


func _on_block_selected(index: int):
	if index < Chunk.block_types.size() and Chunk.block_types.values()[index]["Tags"].has(Chunk.Tags.Dont_List):
		return
	block_dialog.hide()
	selected_block = index
	update_block_preview()
	paused = false
