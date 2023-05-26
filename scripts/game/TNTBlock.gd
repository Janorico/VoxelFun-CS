extends StaticBody


const remove_radius = 5
var pw
var chunk_size
onready var mesh_instance: MeshInstance = $MeshInstance
onready var explosion: CPUParticles = $Explosion
onready var explosion_sound: AudioStreamPlayer3D = $ExplosionSound


func _on_timer_timeout():
	explosion.emitting = true
	explosion_sound.play()
	mesh_instance.hide()
	var changed_chunks: Array = []
	for x in range(translation.x - 5, translation.x + 5):
		for y in range(translation.y - 5, translation.y + 5):
			for z in range(translation.z - 5, translation.z + 5):
				var pos: Vector3 = Vector3(x, y, z)
				# Calculate chunk
				var chunk: Vector3 = pos / chunk_size
				chunk = chunk.floor()
				if not changed_chunks.has(chunk):
					changed_chunks.append(chunk)
				# Calculate position on chunk
				pos = pos - (chunk * chunk_size)
				pw.change_block(chunk.x, chunk.z, pos.x, pos.y, pos.z, "Air", false)
	for c in changed_chunks:
		pw._update_chunk(c.x, c.z)
