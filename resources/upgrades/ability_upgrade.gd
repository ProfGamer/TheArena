extends Resource
class_name AbilityUpgrade

@export var id : String
@export var uuid : int
@export_range(0, 2) var rare : int
# 如果max_quantity == 0 代表可以一直选择的升级
@export var max_quantity : int
@export var name : String
@export_multiline var description : String



