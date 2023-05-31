extends Node


# Config file path
const CONFIG_PATH: String = "user://config.cfg"
# Config sections/keys
const SOUND_SECTION: String = "Sound"
const MASTER_VOLUME: String = "master_volume"
const SFX_VOLUME: String = "sfx_volume"
# Config values
var master_volume: float = 1.0
var sfx_volume: float = 1.0


func _ready():
	read()
	# warning-ignore:return_value_discarded
	connect("tree_exiting", self, "save")


func apply():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))


func read():
	var config_file = ConfigFile.new()
	config_file.load(CONFIG_PATH)
	master_volume = config_file.get_value(SOUND_SECTION, MASTER_VOLUME, master_volume)
	sfx_volume = config_file.get_value(SOUND_SECTION, SFX_VOLUME, sfx_volume)
	apply()


func save():
	var config_file = ConfigFile.new()
	config_file.set_value(SOUND_SECTION, MASTER_VOLUME, master_volume)
	config_file.set_value(SOUND_SECTION, SFX_VOLUME, sfx_volume)
	config_file.save(CONFIG_PATH)
