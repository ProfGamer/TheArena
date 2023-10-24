extends Node2D
@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D


func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	

func  tween_collect(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	# lerp实现瓶子靠近player收集效果
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	# 实现瓶子收集时方向的平滑翻转
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))
	

func collect():
	GameEvent.emit_exp_vial_collected(1)
	queue_free()


func disable_collision():
	collision_shape_2d.disabled = true


# 需要避免Vial在收集的时候触发两次on_area_entered, 在触发之后disable collistionshape, 但是我们不能在物理回调中设置disable
func on_area_entered(other_area: Area2D):
	# 在下一个空闲帧在disable 碰撞
	Callable(disable_collision).call_deferred()
	# 使用补间动画制作玩家收集经验瓶的动画
	var tween = create_tween()
	# 使补间方法同时进行
	tween.set_parallel()
	# 使用bind传入参数到回调方法中
	# 设置Ease 和 trans
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0 , 0.5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.05).set_delay(0.45)
	# 使两个并行的Tween对齐
	tween.chain()
	# tween_callback -> 在补间动画结束之后调用
	tween.tween_callback(collect)
	$RandomStreamPlayer2DComponent.play_random()
	
