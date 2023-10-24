extends PanelContainer
#Signal section
signal selected

@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel
@onready var hover_animation_player = $HoverAnimationPlayer
@onready var panel_container = %PanelContainer

var disabled = false

func _ready():
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)


func play_in(delay:float = 0.0):
	# 先将modulate设置为透明, 然后再动画中将其调整回来
	modulate = Color.TRANSPARENT
	# 创建一次性计时器
	await get_tree().create_timer(delay).timeout
	$AnimationPlayer.play("in")


func play_discard():
	$AnimationPlayer.play("discard")


func set_ability_upgrade(upgrade: AbilityUpgrade):
	if upgrade.rare == 1:
		panel_container.theme_type_variation = "RarePanelContainer"
	elif upgrade.rare == 2:
		panel_container.theme_type_variation = "EpicPanelContainer"
	name_label.text = upgrade.name
	desc_label.text = upgrade.description
	

func select_card():
	disabled = true
	$AnimationPlayer.play("selected")
	for other_card in get_tree().get_nodes_in_group("upgrade_card"):
		if other_card == self:
			continue
		other_card.play_discard()
	# 等动画播放完才发出信号, 取消游戏的暂停
	await $AnimationPlayer.animation_finished
	selected.emit()


func on_gui_input(event: InputEvent):
	if disabled:
		return
	if event.is_action_pressed("left_click"):
		select_card()


func on_mouse_entered():
	if disabled:
		return
	hover_animation_player.play("hover")
