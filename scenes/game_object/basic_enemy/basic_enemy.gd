extends CharacterBody2D

@onready var visual = $Visual
@onready var velocity_component = $VelocityComponent


func _ready():
	$HurtboxComponent.hit.connect(on_hit)

func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visual.scale = Vector2(move_sign, 1)


func on_hit():
	$RandomStreamPlayer2DComponent.play_random()


