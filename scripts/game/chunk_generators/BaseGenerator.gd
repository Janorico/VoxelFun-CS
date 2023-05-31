class_name ChunkGenerator
extends Node


const Chunk = preload("res://scripts/game/Chunk.gd")


static func generate_surface(_height, _x, y, _z):
	if y == 0:
		return "Stone"
	else:
		return "Air"


static func generate_details(c, rng, _ground_height):
	# Place diamond
	var b = c.BlockData.new()
	b.create("Diamond")
	var x = rng.randi_range(0, int(c.DIMENSION.x))
	var y = rng.randi_range(1, 10)
	var z = rng.randi_range(0, int(c.DIMENSION.z))
	c._set_block_data(x, y, z, b, true, false)
