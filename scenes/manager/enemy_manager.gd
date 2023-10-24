extends Node

const SPAWN_RADIUS = 375

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene : PackedScene
@export var lighting_rat_scene : PackedScene
@export var invisible_ghost_scene : PackedScene
@export var arena_time_manager : Node

@onready var timer = $Timer

var base_spawn_time = 0
var enemy_table = WeightedTable.new()

func _ready():
	enemy_table.add_item(1, basic_enemy_scene, 10)
	
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_diffculty_increased.connect(on_arena_diffculty_increased)

func get_spawm_position(player: Node2D):
	# 如果没有玩家 -> 返回一个0向量
	if player == null:
		return Vector2.ZERO
	var spawn_position = Vector2.ZERO
	# 让enemy生成在玩家viewport之外 viewport scale 640 * 360
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		# enemy的位置在玩家的随机方向 random_direction * 330的位置
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var addtional_check_offset = random_direction * 20
		# intersect_ray()方法需要一个对象作为查询参数
		# 传入角色和将要生成enemy的位置, 以及一个碰撞层掩码 1 << 0(层数-1) 因为掩码的value值为1-2-4-8-16所以我们最好直接做移位运算
		var query_param = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + addtional_check_offset, 1 << 0)
		# 在两个位置之间发出一条射线, 看是否与该掩码的碰撞层存在碰撞, 返回一个字典 记录了碰撞信息, 如果没有碰撞则会返回空字典
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_param)
		if result.is_empty():
			# 没有发生碰撞
			break
		else:
			# 将random_direction旋转90°之后再次循环
			random_direction = random_direction.rotated(deg_to_rad(90))
	return spawn_position

func on_timer_timeout():
	timer.start()
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var enemy_scene = enemy_table.pick_item()
	var enemy = enemy_scene.instantiate() as Node2D
	# 与其将生成的Enemy添加到Main节点下, 我们选择将生成的Enemy添加到entities_layer, 这样可是和player实现基于Y轴的位置关系排序
	var entities_layer = get_tree().get_first_node_in_group("entities_layer") as Node2D
	entities_layer.add_child(enemy)
	
	enemy.global_position = get_spawm_position(player)

func on_arena_diffculty_increased(current_diffculty : int):
	var time_off = (0.1/10) * current_diffculty
	time_off = min(float("%.3f" % time_off), .7)
	print("当前难度敌人刷新时间偏移量:" + str(time_off))
	timer.wait_time = base_spawn_time - time_off
	if current_diffculty == 9:
		enemy_table.add_item(3, lighting_rat_scene, 30)
		print("闪电鼠加入竞技场")
	if current_diffculty == 18:
		enemy_table.add_item(2, wizard_enemy_scene, 15)
		print("Wizard加入竞技场")
	if current_diffculty == 27:
		enemy_table.add_item(4, invisible_ghost_scene, 30)
		print("隐身幽灵加入竞技场")
	
