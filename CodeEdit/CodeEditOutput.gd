class_name CodeEditOutput
extends Control

## 输出显示控件，支持固定宽度和可滚动高度
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var button_clear: Button = $ButtonClear


func _ready():
	_init_label_setting()
	button_clear.pressed.connect(clear_output)


func _init_label_setting():
	rich_text_label.selection_enabled = true
	
	# 启用右键菜单（包含复制选项）
	rich_text_label.context_menu_enabled = true
	
	# 启用 BBCode 支持（可选）
	rich_text_label.bbcode_enabled = true
	
	# 设置文本内容
	rich_text_label.text = """
	[center][b]游戏标题[/b][/center]

[color=blue]欢迎来到游戏世界！[/color]

[i]游戏说明：[/i]
• 这是一个冒险游戏
• 你可以选择不同的角色
• 探索神秘的世界

[color=red][b]注意：[/b][/color] 请仔细阅读游戏规则
"""

## 设置输出文本内容
func set_output_text(text: String) -> void:
	"""设置输出文本内容"""
	rich_text_label.text = text

## 添加输出文本内容（追加模式）
func append_output_text(text: String) -> void:
	"""追加输出文本内容"""
	rich_text_label.append_text(text)

## 清空输出内容
func clear_output() -> void:
	"""清空所有输出内容"""
	rich_text_label.text = ""
	YanGF.Log.clear_log_files()

## 获取当前输出内容
func get_output_text() -> String:
	"""获取当前输出内容"""
	return rich_text_label.text



