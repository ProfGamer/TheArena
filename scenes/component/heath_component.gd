extends Node
class_name HeathComponent
@export var max_heath: float = 10

signal died
signal health_changed

var current_health

func _ready():
	current_health = max_heath

func damage(damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit()
	# 延迟调用 等到下一个空闲帧再调用
	Callable(check_death).call_deferred()

func change_max_hp(increase):
	max_heath += increase
	current_health += increase


func check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()
		
		
func get_health_percent():
	if max_heath <= 0:
		return 0
	else:
		return min(current_health / max_heath, 1)
		
