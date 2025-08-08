class_name YanCodeEdit


extends CodeEdit


@export var output_label:Label
@export var code_run_button:Button


func _ready():
	

	self.code_completion_prefixes = PackedStringArray(
		["p"],
	)
	
	# 设置 Gutter 相关属性
	setup_gutters()
	setup_code_run()
	
	# 连接信号到函数
	self.text_changed.connect(_on_text_changed)
	self.code_completion_requested.connect(_on_code_completion_requested)
	
	# 检查信号是否连接成功
	print("信号连接状态: ", self.text_changed.get_connections())



func setup_code_run():

	self.code_run_button.pressed.connect(func():
		code_run(self,self.output_label)
	)

	

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




func code_run(input:TextEdit,output:Label):
	# 获取用户输入的代码字符串
	var user_code = input.text
	
	# 检查用户输入是否为空
	if user_code.is_empty():
		output.text = "请输入代码！"
		return
	
	# 创建动态脚本
	var script = GDScript.new()
	
	# 构建完整的脚本代码
	# 为用户代码的每一行添加缩进
	var indented_code = ""
	# var lines = user_code.split("\n")
	# for line in lines:
	# 	if line.strip_edges() != "":  # 跳过空行
	# 		indented_code += "\t" + line + "\n"
	
	var full_code = """
extends RefCounted
%s
""" % user_code
	
	# 设置脚本源代码
	script.set_source_code(full_code)
	
	# 重新加载脚本
	script.reload()
	
	# 创建实例并执行
	var instance = script.new()
	
	# 执行用户代码
	var result = instance.test()
	output.text = "代码执行成功！\n结果: " + str(result)
	print("用户代码执行结果: ", result)




func test():
	return "Hello from dynamic code!"







