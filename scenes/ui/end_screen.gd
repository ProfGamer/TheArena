extends CanvasLayer

@onready var panel_container = %PanelContainer

func _ready():
	# 将动画的原点设置为panel container的中心
	panel_container.pivot_offset = panel_container.size / 2
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	get_tree().paused = true
	%ContinueButton.pressed.connect(on_continue_button_pressed)
	%QuitButton.pressed.connect(on_quit_button_pressed)
	
	
func set_defeat(time_elapsed : String):
	%TitleLabel.text = 	"寄!"
	%DescLabel.text = "没关系, " + time_elapsed + "秒也很棒了"
	play_jingle(true)


func play_jingle(defeat : bool = false):
	if defeat:
		$DefeatStreamPlayer.play()
	else:
		$VictoryStreamPlayer.play()


func on_continue_button_pressed():
	# 播放场景过渡
#	ScreenTransition.transition()
#	# 放到一半的时候切换场景
#	await  ScreenTransition.transition_halfway
	get_tree().paused = false
	# 跳转到升级界面
	get_tree().change_scene_to_file("res://scenes/ui/meta_menu.tscn")
	
	
func on_quit_button_pressed():
	ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")
#	await ScreenTransition.transition_halfway
	get_tree().paused = false
