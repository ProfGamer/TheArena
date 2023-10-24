extends Node

@export var health_component : Node
@export var sprite : Sprite2D
@export var hit_flash_material : ShaderMaterial
var hit_flash_tween: Tween

func _ready():
	# 监听受击信号
	health_component.health_changed.connect(on_health_changed)
	# 设置Sprite的shader matiral
	sprite.material = hit_flash_material
 
func on_health_changed():
	# 如果补间动画正在进行中 那么就kill掉重新动画
	if hit_flash_tween != null && hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	# 受击时将敌人像素调整为全白不透明
	(sprite.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)
	hit_flash_tween = create_tween()
	# 然后在补间动画中慢慢恢复敌人的透明度
	hit_flash_tween.tween_property(sprite.material, "shader_parameter/lerp_percent", 0.0, 0.2)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
