extends Node


# 创建自定义信号
signal exp_vial_collected(number: float)
# 创建自定义信号 用于技能升级
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
# 创建玩家被攻击信号
signal player_damaged


# 在这个方法中发送自定义信号
func emit_exp_vial_collected(number: float):
	exp_vial_collected.emit(number)

func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)
	

func emit_player_damaged():
	player_damaged.emit()
