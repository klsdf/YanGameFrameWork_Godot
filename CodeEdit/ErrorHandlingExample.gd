extends Control

"""
错误处理系统使用示例
展示如何使用错误处理器来捕捉和处理各种错误
"""

@onready var code_edit: YanCodeEdit = $VBoxContainer/CodeEditContainer/CodeEdit
@onready var output_label: Label = $VBoxContainer/CodeEditContainer/OutputContainer/OutputLabel
@onready var run_button: Button = $VBoxContainer/CodeEditContainer/OutputContainer/ButtonContainer/RunButton
@onready var show_error_log_button: Button = $VBoxContainer/CodeEditContainer/OutputContainer/ButtonContainer/ShowErrorLogButton
@onready var clear_log_button: Button = $VBoxContainer/CodeEditContainer/OutputContainer/ButtonContainer/ClearLogButton

func _ready():
	# 设置代码编辑器的输出标签
	code_edit.output_label = output_label
	
	# 连接按钮信号
	run_button.pressed.connect(_on_run_button_pressed)
	show_error_log_button.pressed.connect(_on_show_error_log_button_pressed)
	clear_log_button.pressed.connect(_on_clear_log_button_pressed)
	
	# 设置默认代码
	code_edit.text = """func test():
	return "Hello World!""""

func _on_run_button_pressed():
	"""
	运行代码按钮被点击
	"""
	# 直接调用代码编辑器的运行函数
	code_edit.code_run(code_edit, output_label)

func _on_show_error_log_button_pressed():
	"""
	显示错误日志按钮被点击
	"""
	if code_edit.error_display:
		code_edit.error_display.show_error_log()
	else:
		output_label.text = "错误显示UI未初始化"

func _on_clear_log_button_pressed():
	"""
	清空错误日志按钮被点击
	"""
	if code_edit.error_handler:
		code_edit.error_handler.clear_error_log()
		output_label.text = "错误日志已清空"
	else:
		output_label.text = "错误处理器未初始化"

func _input(event):
	"""
	处理输入事件
	"""
	if event is InputEventKey and event.pressed:
		# Ctrl+R 运行代码
		if event.keycode == KEY_R and event.ctrl_pressed:
			_on_run_button_pressed()
		# Ctrl+L 显示错误日志
		elif event.keycode == KEY_L and event.ctrl_pressed:
			_on_show_error_log_button_pressed()
		# Ctrl+K 清空错误日志
		elif event.keycode == KEY_K and event.ctrl_pressed:
			_on_clear_log_button_pressed()
