extends CanvasLayer
#Signal section
# 在发送信号的时候也可以携带参数
signal upgrade_selected(upgrade: AbilityUpgrade)

@onready var card_container: HBoxContainer = %CardContainer
@export var upgrade_card_scene: PackedScene

func _ready():
	get_tree().paused = true


func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):
	var delay = 0
	# 遍历数组中的每个upgrade
	for upgrade in upgrades:
	
		# 实例化每个升级对象为upgrade_card_scene
		var card_instance = upgrade_card_scene.instantiate()
		# 将每个实例都加入card container中, 他们将自动水平排列
		card_container.add_child(card_instance)
		card_instance.set_ability_upgrade(upgrade)
		card_instance.play_in(delay)
		# bind能让我们在使用connect监听处理信号的时候, 将参数传入方法中
		card_instance.selected.connect(on_card_selected.bind(upgrade))
		delay += 0.2
		
	
func on_card_selected(upgrade: AbilityUpgrade):
	# 如果我们的信号制定了传入的参数, 我们就可以在emit信号的时候传入参数
	upgrade_selected.emit(upgrade)
	$AnimationPlayer.play("out")
	await $AnimationPlayer.animation_finished
	# 在选择完升级之后结束游戏暂停, 并清理掉该upgrade screen
	get_tree().paused = false
	queue_free()
