extends Resource
class_name MetaUpgrade

@export var id : String
@export var max_quantity : int = 1
@export_range(0,2) var rare : int = 0
# Meta升级的所需消耗经验值
@export var exp_cost : int = 10
@export var title : String
@export_multiline var description : String
