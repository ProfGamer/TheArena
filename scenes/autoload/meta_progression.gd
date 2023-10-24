extends Node

const SAVE_FILE_PATH = "user://game.save"

var save_data : Dictionary = {
	"meta_upgrade_currency" : 0,
	"meta_upgrades" : {}
}


func _ready():
	# 每次经验收集的时候, 增加meta_upgrade_currency
	GameEvent.exp_vial_collected.connect(on_exp_collected)
	# 测试方法
	# add_meta_upgrade(load("res://resources/meta_upgrades/exp_gain.tres"))
	load_save_file()
	


func load_save_file():
	# 从储存文件目录尝试读取存档文件
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		return
	# 如果文件存在就从文件路径读取文件
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	# 然后获取上次存储的save data字典
	save_data = file.get_var()


func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	


func add_meta_upgrade(upgrade : MetaUpgrade):
	if !save_data["meta_upgrades"].has(upgrade.id):
		save_data["meta_upgrades"][upgrade.id] = {
			"quantity" : 0
		}
	save_data["meta_upgrades"][upgrade.id]["quantity"] += 1
	save_data["meta_upgrade_currency"] -= upgrade.exp_cost
	save()


# 通过升级id获取该技能被购买的次数
func get_meta_upgrade_count(upgrade_id : String) -> int:
	if save_data["meta_upgrades"].has(upgrade_id):
		return save_data["meta_upgrades"][upgrade_id]["quantity"]
	else:
		return 0
	


func on_exp_collected(number : float):
	save_data["meta_upgrade_currency"] += number
	#save()


