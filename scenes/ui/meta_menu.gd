extends CanvasLayer
@onready var grid_container = %GridContainer
@onready var back_button = %BackButton

# 导出一个MetaUpgrade数组
@export var upgardes : Array[MetaUpgrade] = []
# 预加载升级卡场景
var meta_upgrade_card_scene = preload("res://scenes/ui/meta_upgrade_card.tscn")


func _ready():
	# 测试目的, 先清除占位Card
	for child in grid_container.get_children():
		child.queue_free()
	back_button.pressed.connect(on_back_pressed)
	for upgrade in upgardes:
		var meta_upgarde_card_instance = meta_upgrade_card_scene.instantiate()
		grid_container.add_child(meta_upgarde_card_instance)
		meta_upgarde_card_instance.set_meta_upgrade(upgrade)


func on_back_pressed():
	ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")
