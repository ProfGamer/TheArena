extends Node

# 每隔5秒增加游戏难度
const DIFFCULTY_INTERVAL = 5
# 每次增加游戏难度时, 发出信号
signal arena_diffculty_increased(arena_diffculty:int)
@export var end_screen_scene: PackedScene
@onready var timer = $Timer

# 随时间增加的游戏难度
var arena_diffculty = 0


func _ready():
	timer.timeout.connect(on_timer_timeout)


func _process(delta):
	# 下一次增长游戏难度的游戏时间(timer.time_left)
	var next_target_time = timer.wait_time - ((arena_diffculty + 1) * DIFFCULTY_INTERVAL)
	if timer.time_left <= next_target_time:
		arena_diffculty += 1
		arena_diffculty_increased.emit(arena_diffculty)
		print("现在的游戏难度:" + str(arena_diffculty))

	
# 返回已经经过的时间
func get_time_elapsed():
	return timer.wait_time - timer.time_left


func on_timer_timeout():
	var victory_screen_instance = end_screen_scene.instantiate()
	add_child(victory_screen_instance)
	victory_screen_instance.play_jingle()
	MetaProgression.save()
