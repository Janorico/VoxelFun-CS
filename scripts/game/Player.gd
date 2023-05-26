class_name Player
extends KinematicBody

onready var stair_detector: RayCast = $StairDetector
onready var camera = $CameraBase/Camera
onready var camera_base = $CameraBase
onready var raycast = $CameraBase/Camera/RayCast
onready var info_label = $CameraBase/Camera/InfoLabel
onready var headlamp: SpotLight = $CameraBase/Camera/Headlamp
# Reset values
onready var initial_position: Vector3 = translation
onready var initial_rotation: Vector3 = rotation_degrees

var Chunk = load("res://scripts/game/Chunk.gd")
var selected_block = Chunk.block_types.keys()[0]
var selected_block_index = 0
export var selected_block_texture: AtlasTexture

var camera_x_rotation = 0

const mouse_sensitivity = 0.3
const SPEED = 5
var velocity = Vector3.ZERO
const gravity = 9.8
var jump_vel = 5
var fly: bool = false

var paused = false

signal place_block(pos, norm, type)
signal place_tnt_block(pos, norm)
signal destroy_block(pos, norm)
signal highlight_block(pos, norm)
signal unhighlight_block()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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
	info_label.text = "Selected block %s, Chunk (%d, %d) pos (%d, %d, %d)" % [selected_block, cx, cz, px, py, pz]
	if not paused:
		# Check the raycast
		if raycast.is_colliding():
			var pos = raycast.get_collision_point()
			var norm = raycast.get_collision_normal()
			emit_signal("highlight_block", pos, norm)
			if Input.is_action_just_pressed("click"):
				print("Click")
				emit_signal("destroy_block", pos, norm)
			elif Input.is_action_just_pressed("right_click"):
				if Input.is_action_pressed("place_tnt_block"):
					emit_signal("place_tnt_block", pos, norm)
				else:
					emit_signal("place_block", pos, norm, selected_block)
		else:
			emit_signal("unhighlight_block")
		
		# Scroll to change block
		if Input.is_action_just_released("scroll_up"):
			selected_block_index -= 1
			if selected_block_index < 0:
				selected_block_index += Chunk.block_types.keys().size()
		elif Input.is_action_just_released("scroll_down"):
			selected_block_index += 1
			if selected_block_index >= Chunk.block_types.keys().size():
				selected_block_index -= Chunk.block_types.keys().size()
		selected_block = Chunk.block_types.keys()[selected_block_index]
		var block = Chunk.block_types[selected_block]
		if block.has(Chunk.Side.left):
			selected_block_texture.region.position = block[Chunk.Side.left] * 16
		elif block.has(Chunk.Side.only):
			selected_block_texture.region.position = block[Chunk.Side.only] * 16
		else:
			selected_block_texture.region.position = Vector2(-16, -16)
		
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
