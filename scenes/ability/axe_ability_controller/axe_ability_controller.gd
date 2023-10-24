extends Node
@export var axe_ability_scene: PackedScene
@onready var timer = $Timer

var base_damage = 10
var enable_critical = false
var enable_execute = false
var additional_damage_percent = 1
var radius_increase = 0

func _ready():
	timer.timeout.connect(on_timer_timeout)
	GameEvent.ability_upgrade_added.connect(on_ability_upgrade_added)
	
	
func on_timer_timeout():
	var axe_instance = axe_ability_scene.instantiate() as Node2D
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
	foreground.add_child(axe_instance)
	axe_instance.global_position = player.global_position
	axe_instance.radius_increase = radius_increase
	var total_damage = base_damage * additional_damage_percent
	if enable_execute && randf() < 0.05:
		total_damage = 999999
	elif enable_critical && randf() < 0.3:
		total_damage = total_damage * 1.5
	axe_instance.hitbox_component.damage = total_damage


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (0.1 * current_upgrades["axe_damage"]["quantity"])
	print("Axe Damage: " + str(base_damage * additional_damage_percent))
	if upgrade.id == "critical_hit":
		enable_critical = true
	if upgrade.id == "axe_range":
		radius_increase = current_upgrades["axe_range"]["quantity"] * 20
	if upgrade.id == "axe_execute":
		enable_execute = true
