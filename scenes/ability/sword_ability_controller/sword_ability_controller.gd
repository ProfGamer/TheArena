extends Node
const MAX_RANGE = 150
# 导出一个sword_ability的属性, 值类型是PackedScene
@export var sword_ability: PackedScene
var base_damage = 5
var additional_damage_percent = 1
var base_wait_time
var enable_critical : bool = false
var enable_multiple_sword : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvent.ability_upgrade_added.connect(on_ability_upgrade_added)
	handle_meta_upgrade()


func handle_meta_upgrade():
	var base_damage_increase = MetaProgression.get_meta_upgrade_count("sword_damage_up")
	base_damage += base_damage_increase


func on_timer_timeout():
	# 获得player节点
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	# 获得enemy节点数组
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	# lamda filter, 获得和player之间距离的平方小于MaxRange平方的enemy数组
	enemies = enemies.filter(func(enemy: Node2D): 
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)	
#	# 获得距离最近的敌人并攻击他
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	if enemies.size() == 0:
		return
	var sword_quantity = 1
	if enable_multiple_sword && randf() < 0.2:
		sword_quantity = 3
	for i in sword_quantity:
		var sword_instance = sword_ability.instantiate() as Node2D
		# 将sword_ability放到前景层, 而不是直接放在main中
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer") as Node2D
		foreground_layer.add_child(sword_instance)
		# 将伤害值传入hitbox
		var total_damage = base_damage * additional_damage_percent
		if enable_critical && randf() < 0.3:
			total_damage = total_damage * 1.5
		sword_instance.hitbox_component.damage = total_damage
	#	# 默认的位置会在00原点
		sword_instance.global_position = enemies[0].global_position
		# 为了使得剑的位置不和敌人的位置重合因此导致判定不灵敏 我们将剑的位置在敌人位置基础上进行一定的偏移
		sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
		
		var enemy_direction = enemies[0].global_position - sword_instance.global_position
		sword_instance.rotation = enemy_direction.angle()
	


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	# 在这里根据技能升级重新设置timer的wait time
	if upgrade.id == "sword_rate":
		var percent_reduction = current_upgrades["sword_rate"]["quantity"] * .1
		$Timer.wait_time = base_wait_time * (1 - percent_reduction)
		$Timer.start()
	if upgrade.id == "sword_base_up":
		base_damage += 1
	if upgrade.id == "sword_damage":
		additional_damage_percent = 1 + (0.15 * current_upgrades["sword_damage"]["quantity"])
	if upgrade.id == "critical_hit":
		enable_critical = true
	if upgrade.id == "sword_triple":
		enable_multiple_sword = true
	print("Sword Damage: " + str(base_damage * additional_damage_percent))
	print($Timer.wait_time)
