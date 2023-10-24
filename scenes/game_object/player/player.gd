extends CharacterBody2D

# 记录当前与玩家碰撞的敌人的数量
var number_colliding_bodies = 0

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar
@onready var ability = $Ability
@onready var animation_player = $AnimationPlayer
@onready var visual = $Visual
@onready var velocity_component = $VelocityComponent

var base_speed = 0
var enable_dodge = false

func _ready():
	base_speed = velocity_component.max_speed
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	GameEvent.ability_upgrade_added.connect(on_ability_upgrade_added)
	handle_meta_upgrade()
	update_health_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement_vector = get_movement_vector()
	# 斜向的向量会导致速度大于预期, 所以我们需要对从输入得到的movement_vector进行标准化
	# 这样我们就可以得到各方向单位是1的向量了
	var direction = movement_vector.normalized()
	# 使用velocity component 实现移动
	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)
	

	# 当玩家的输入确实能导致角色在x或y轴的移动时, 播放角色的walk动画
	if movement_vector.x != 0 || movement_vector.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
	
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visual.scale = Vector2(move_sign, 1)

func handle_meta_upgrade():
	var hp_increase = MetaProgression.get_meta_upgrade_count("hp_up")
	health_component.change_max_hp(hp_increase)


func get_movement_vector():
	
	# 从玩家的输入中得出玩家想要移动的方向
	# Input.get_action_strength对于键盘会返回0(未按下) 或 1(按下)
	# 对于摇杆则会返回一个0-1之间的double, 显示摇杆被推向的距离
	# 使用right - left的结果, 如果为正数 则向右移动, 负数向左移动, 为0则x方向不移动
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	# 同理我们对y轴也进行处理
	# 注意, godot中游戏界面位于第四象限, x轴向右为正, y轴向下为正, 所以我们使用右减左, 下减上
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)	


func check_deal_damage():
	# 当没有敌人碰撞以及刚受过伤害计时器还在运转时, 不会收到伤害
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	var real_damage = 1
	if enable_dodge && randf() < 0.2:
		real_damage = 0
	health_component.damage(real_damage)
	damage_interval_timer.start()
	print(health_component.current_health)


func update_health_display():
	health_bar.value = health_component.get_health_percent()

func on_body_entered(body: Node2D):
	number_colliding_bodies += 1
	check_deal_damage()

	
func on_body_exited(body: Node2D):
	number_colliding_bodies -= 1


func on_damage_interval_timer_timeout():
	check_deal_damage()
	
	
func on_health_changed():
	$RandomStreamPlayer2DComponent.play_random()
	GameEvent.emit_player_damaged()
	update_health_display()
	

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade is Ability:
		var ability_upgrade = upgrade as Ability
		# 如果升级选中的是Ability,
		# 那么就将该Ability的AbilityControllerScene实例化后加入ability的子节点
		var ability_controller_instance = ability_upgrade.ability_controller_scene.instantiate()
		ability.add_child(ability_controller_instance)
		if current_upgrades.has("critical_hit"):
			ability_controller_instance.enable_critical = true
	elif upgrade.id == "player_speed":
		velocity_component.max_speed += 10
		print("当前角色速度: " + str(velocity_component.max_speed))
	elif upgrade.id == "dodge":
		enable_dodge = true
	elif upgrade.id == "last_dance":
		velocity_component.max_speed += base_speed
		health_component.current_health = 1
		update_health_display()
