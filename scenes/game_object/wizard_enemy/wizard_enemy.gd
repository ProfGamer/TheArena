extends CharacterBody2D


# Ctrl + 拖拽节点进入脚本 = 自动生成@onready引用
@onready var visual = $Visual
@onready var velocity_component = $VelocityComponent

var is_moving = false


func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(delta):
	if is_moving:
		velocity_component.accelerate_to_player()
	else:
		velocity_component.decelerate()
	velocity_component.move(self)
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visual.scale = Vector2(move_sign, 1)


func set_is_moving(moving : bool):
	is_moving = moving


func on_hit():
	$RandomStreamPlayer2DComponent.play_random()
