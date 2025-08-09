extends CodeEdit

func _ready():
	

	self.code_completion_prefixes = PackedStringArray(
		["p"],
	)
	
	# 设置 Gutter 相关属性
	setup_gutters()
	
	# 连接信号到函数
	self.text_changed.connect(_on_text_changed)
	self.code_completion_requested.connect(_on_code_completion_requested)
	
	# 检查信号是否连接成功
	print("信号连接状态: ", self.text_changed.get_connections())

func setup_gutters():
	"""
	设置 Gutter 的各种显示选项
	"""


	# 代码补全
	self.code_completion_enabled = true

	# 行号设置
	self.gutters_draw_line_numbers = true
	# 绘制执行行
	self.gutters_draw_executing_lines = true

	# 行号补零
	self.gutters_zero_pad_line_numbers = true


	# 代码折叠
	self.line_folding = true
	self.gutters_draw_fold_gutter = true


	#制表符绘制
	self.draw_tabs = true
	self.draw_spaces = true


	#断点
	self.gutters_draw_breakpoints_gutter = true







	
func _on_text_changed() -> void:
	print("_on_text_changed() 函数被调用了！")
	self.code_completion_requested.emit()



func _on_code_completion_requested() -> void:
	if self.text=="p":
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print", "print()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_debug", "print_debug()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_verbose", "print_verbose()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_warning", "print_warning()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_error", "print_error()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_fatal", "print_fatal()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_script", "print_script()")
		self.update_code_completion_options(false)

