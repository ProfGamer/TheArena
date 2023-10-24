extends CanvasLayer

# 因为这个返回按钮不止用于主界面, 还可以在游戏中呼出, 所以不可以直接使用Button.pressed信号
signal back_pressed

@onready var sfx_slider = %SfxSlider
@onready var music_slider = %MusicSlider
@onready var back_button = %BackButton


func _ready():
	back_button.pressed.connect(on_back_button_pressed)
	%WindowModeButton.pressed.connect(on_window_mode_button_pressed)
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind( "sfx"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
	update_display()

func update_display():
	%WindowModeButton.text = "窗口化"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		%WindowModeButton.text = "全屏"
	sfx_slider.value = get_bus_volume_percent("sfx")
	music_slider.value = get_bus_volume_percent("music")
	
	
func get_bus_volume_percent(bus_name : String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name : String, percent : float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func on_window_mode_button_pressed():
	# 获得当前的window mode
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_display()


func on_audio_slider_changed(persent: float, bus_name : String):
	set_bus_volume_percent(bus_name, persent)


func on_back_button_pressed():
	back_pressed.emit()
