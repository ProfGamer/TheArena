extends Camera2D
var target_position = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	# 当场景准备好时, 使用current camera
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# 为了实现和帧速率无关的平滑相机, 需要使用lerp
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20))
	
		

func acquire_target():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		# 因为节点列表中全部都是父类node, 如果我们知道所选的节点具体时哪种时
		# 可以使用 as 关键字来做casting
		var player = player_nodes[0] as Node2D
		target_position = player.global_position
