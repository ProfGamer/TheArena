extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel
@onready var progress_bar = %ProgressBar
@onready var purchase_button = %PurchaseButton
@onready var progress_label = %ProgressLabel
@onready var count_label = %CountLabel


# 需要把card对应的升级保存下来
var upgrade : MetaUpgrade

func _ready():
	gui_input.connect(on_gui_input)
	purchase_button.pressed.connect(on_purchase_pressed)

func set_meta_upgrade(upgrade: MetaUpgrade):
	# 给成员变量赋值
	self.upgrade = upgrade
	name_label.text = upgrade.title
	desc_label.text = upgrade.description
	update_progress()


# 当我们获取Meta升级之后, 需要更新所有Card的进度条
func update_progress():
	var current_currency = MetaProgression.save_data["meta_upgrade_currency"]
	var require_currency = self.upgrade.exp_cost
	var current_quantity = MetaProgression.save_data["meta_upgrades"][self.upgrade.id]["quantity"]\
	if MetaProgression.save_data["meta_upgrades"].has(self.upgrade.id) else 0
	var percent = current_currency / self.upgrade.exp_cost
	var is_max_purchase = current_quantity >= upgrade.max_quantity
	# 防止percent值大于1
	percent = min(percent, 1)
	progress_bar.value = percent
	# 如果不够购买, 那么就禁用购买按钮 如果已经达到最大数量 也禁止购买
	purchase_button.disabled = percent < 1 || is_max_purchase
	if is_max_purchase:
		purchase_button.text = "已最大"
	progress_label.text = "%s/%s" % [str(current_currency), str(require_currency)]
	count_label.text = "x(%s/%s)" % [current_quantity, upgrade.max_quantity]


func select_card():
	$AnimationPlayer.play("selected")


func on_gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		select_card()


func on_purchase_pressed():
	if self.upgrade == null:
		return
	MetaProgression.add_meta_upgrade(self.upgrade)
	# 为分组中的所有Card执行update_progress
	get_tree().call_group("meta_upgrade_card", "update_progress")
	$AnimationPlayer.play("selected")
