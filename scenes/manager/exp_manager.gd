extends Node

signal exp_updated(current_exp: float, target_exp: float)
signal level_up(new_level:int)

const TARGET_EXP_GROWTH = 5
var current_exp = 0
var current_level = 1
var target_exp = 5


func _ready():
	# 接收来自GameEvent发出的信号
	GameEvent.exp_vial_collected.connect(on_exp_vial_collected)

func increment_exp(number:float):
	# currentExp改为 相加之后的经验 与 targetExp之间的较小值
	current_exp = min(current_exp + number, target_exp)
	exp_updated.emit(current_exp, target_exp)
	if current_exp == target_exp:
		# 提升等级
		current_level += 1
		# 增加升到下一级所需要的经验
		target_exp += TARGET_EXP_GROWTH
		# 重置当前经验
		current_exp = 0
		# 发出经验增加信号
		exp_updated.emit(current_exp, target_exp)
		# 发出升级信号
		level_up.emit(current_level)


func on_exp_vial_collected(number: float):
	# 处理收集经验信号
	increment_exp(number)
