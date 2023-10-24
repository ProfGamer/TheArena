extends Node

@export_range(0,1) var drop_percent: float = .5
@export var health_component: Node
@export var vial_scene: PackedScene
var exp_increase = 0
func _ready():
	(health_component as HeathComponent).died.connect(on_died)
	change_drop_percent()


func change_drop_percent():
	exp_increase += MetaProgression.get_meta_upgrade_count("exp_gain_1") * 0.1
	exp_increase += MetaProgression.get_meta_upgrade_count("exp_gain_2") * 0.2
	exp_increase += MetaProgression.get_meta_upgrade_count("exp_gain_2") * 0.3
	drop_percent = min(1.0, drop_percent + exp_increase)


func on_died():
	
	if randf() > drop_percent:
		return
	if vial_scene == null:
		return
	if not owner is Node2D:
		return
	
	var spwan_position = (owner as Node2D).global_position
	var vial_instance = vial_scene.instantiate() as Node2D
	# owner.get_parent().add_child(vial_instance)
	var entities_layer = get_tree().get_first_node_in_group("entities_layer") as Node2D
	entities_layer.add_child(vial_instance)
	vial_instance.global_position = spwan_position
	
