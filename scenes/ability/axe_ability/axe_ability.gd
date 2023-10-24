extends Node2D
# 我们希望斧头可以围着玩家绕两圈, 并不断扩大旋转半径
# 设置一个斧头旋转的最大半径
const BASE_RADIUS = 100
var radius_increase = 0
@onready var hitbox_component = $HitboxComponent

var base_rotation = Vector2.RIGHT

func _ready():
	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var tween = create_tween()
	# tween_method是一个一直被持续调用的回调方法, From, To, Duration
	# 在From 和 To之间的一个rotation参数会被传入到回调方法中, 因为我们想要转两圈, 所以0.0 - 2.0
	tween.tween_method(tween_method, 0.0, 2.0, 3)
	tween.tween_callback(queue_free)
	
	
func tween_method(rotation: float):
	# 这里我们计算补间进行的百分比
	var percent = rotation / 2.0
	# 计算不断扩大的旋转半径应该是多少
	var current_radius = percent * (BASE_RADIUS + radius_increase)
	# 计算旋转方向0-2 TAU, 转两圈
	var current_direction = base_rotation.rotated(rotation * TAU)
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	# 因为tween_method是一直进行的, 所以斧子旋转圆心会自动一直跟随着player
	global_position = player.global_position + (current_radius * current_direction)
