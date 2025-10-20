extends Button

class_name YanButton

@onready var red_dot: Panel = $RedDot


## 显示红点
func show_red_dot() -> void:	
	red_dot.visible = true


## 隐藏红点
func hide_red_dot() -> void:
	red_dot.visible = false
