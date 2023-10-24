extends Node2D

@export var health_component : Node
# 导出一个Sprite2D属性, 这样可以使每个敌人的死亡动画根据他自己的纹理来同步
@export var sprite : Sprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	# 设置粒子节点中的纹理
	$GPUParticles2D.texture = sprite.texture
	health_component.died.connect(on_died)


func on_died():
	if owner == null || not owner is Node2D:
		return
	var enemy_position = owner.global_position
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	get_parent().remove_child(self)
	entities_layer.add_child(self)
	global_position = enemy_position
	animation_player.play("default")
	$RandomStreamPlayer2DComponent.play_random()
	
