class_name ChunkGenerator
extends Node


const Chunk = preload("res://scripts/game/Chunk.gd")


static func generate_surface(_height, _x, y, _z):
	if y == 0:
		return "Stone"
	else:
		return "Air"


static func generate_details(_c, _rng, _ground_height):
	return
