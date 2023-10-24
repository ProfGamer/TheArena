extends Node


@export var exp_manager : Node
@export var upgrade_screen_scene : PackedScene

# 已有升级的字典
var current_upgrades = {}
# 根据已有的升级选择upgrade_pool
var upgrade_pool : WeightedTable = WeightedTable.new()
# 先预加载我们所有的升级
var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_range = preload("res://resources/upgrades/axe_range.tres")
var upgrade_axe_execute = preload("res://resources/upgrades/axe_execute.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")
var upgrade_critical_hit = preload("res://resources/upgrades/critical_hit.tres")
var upgrade_sword_triple = preload("res://resources/upgrades/sword_triple.tres")
var upgrade_dodge = preload("res://resources/upgrades/dodge.tres")
var upgrade_last_dance = preload("res://resources/upgrades/last_dance.tres")
var upgrade_sword_base_up = preload("res://resources/upgrades/sword_base_up.tres")

func _ready():
	upgrade_pool.add_item(upgrade_sword_rate.uuid, upgrade_sword_rate, 12)
	upgrade_pool.add_item(upgrade_sword_base_up.uuid, upgrade_sword_base_up, 12)
	upgrade_pool.add_item(upgrade_sword_damage.uuid, upgrade_sword_damage, 12)
	upgrade_pool.add_item(upgrade_player_speed.uuid, upgrade_player_speed, 6)
	upgrade_pool.add_item(upgrade_critical_hit.uuid, upgrade_critical_hit, 6)
	upgrade_pool.add_item(upgrade_sword_triple.uuid, upgrade_sword_triple, 3)
	upgrade_pool.add_item(upgrade_dodge.uuid, upgrade_dodge, 6)
	upgrade_pool.add_item(upgrade_last_dance.uuid, upgrade_last_dance, 3)
	handle_meta_upgrade()
	exp_manager.level_up.connect(on_level_up)
	
	

func update_upgrade_pool(chosen_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if chosen_upgrade.id == upgrade_axe.id && current_upgrades[upgrade_axe.id]["quantity"] < upgrade_axe.max_quantity:
		upgrade_pool.add_item(upgrade_axe_damage.uuid, upgrade_axe_damage, 12)
		upgrade_pool.add_item(upgrade_axe_range.uuid, upgrade_axe_range, 12)
		upgrade_pool.add_item(upgrade_axe_execute.uuid, upgrade_axe_execute, 3)


# 从升级池中选择本次升级所能选择的技能升级对象
func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	var loop_size = min(3, upgrade_pool.items.size())
	for i in loop_size: # 先一次选两个升级
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades)
		chosen_upgrades.append(chosen_upgrade)
	return chosen_upgrades


func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	# 如果当前的升级不在字典中, 则加入字典
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource" : upgrade,
			"quantity" : 1
		}
	# 如果已经在字典中, 将对应的upgrade的quantity + 1
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	# 如果选择完之后该AbilityUpgrade已经到达了MaxQuantity, 那么就需要将该AbilityUpgrade从upgrade_pool中过滤掉
	if upgrade.max_quantity != 0 && current_upgrades[upgrade.id]["quantity"] == upgrade.max_quantity: # 该Upgrade存在选择次数限制
		print("Max Select " + upgrade.id)
		print("Remove " + upgrade.id)
		upgrade_pool.remove_item(upgrade)
	update_upgrade_pool(upgrade, current_upgrades)
	GameEvent.emit_ability_upgrade_added(upgrade, current_upgrades)


func handle_meta_upgrade():
	var axe_enable = MetaProgression.get_meta_upgrade_count("weapon_master") > 0
	if axe_enable:
		upgrade_pool.add_item(upgrade_axe.uuid, upgrade_axe, 30)


func on_level_up(current_level:int):
	# 选择升级池中的随机元素
	
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	# 让upgrade screen实例监听信号upgrade_selected, 将对应的upgrade加入字典
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)


# 信号upgrade_selected在由具体的card发出的时候, 就已经携带了该AbilityUpgrade对象作为参数
func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)


	
