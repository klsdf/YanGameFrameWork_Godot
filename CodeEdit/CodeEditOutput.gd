class_name CodeEditOutput
extends Control

## 输出显示控件，支持固定宽度和可滚动高度
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var button_clear: Button = $ButtonClear


func _ready():
	button_clear.pressed.connect(clear_output)

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



