extends ChunkGenerator


static func generate_surface(height, _x, y, _z):
	var type
	if y == height - 1:
		type = "Grass"
	elif y == height -2:
		type = "Dirt"
	elif y == height - 3 or y == height - 4:
		type = "Stone"
	elif y < height - 14 or y == 0:
		type = "Stone"
	else:
		type = "Air"
	return type
