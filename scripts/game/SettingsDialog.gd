extends ConfirmationDialog


onready var master_slider: HSlider = $GridContainer/MasterSlider
onready var sfx_slider: HSlider = $GridContainer/SFXSlider


func _on_confirmed():
	Global.master_volume = master_slider.value
	Global.sfx_volume = sfx_slider.value
	Global.save()
	Global.apply()


func _on_about_to_show():
	Global.read()
	master_slider.value = Global.master_volume
	sfx_slider.value = Global.sfx_volume
