class_name YanCodeEdit
extends CodeEdit

@export var output_label: CodeEditOutput
@export var code_run_button: Button


# 预加载DialogSystem类

@export var dialog_system: DialogSystem




# 预加载本地 GDScript 语言服务器客户端

# 预加载自定义语法高亮器
const CustomSyntaxHighlighter = preload("res://YanGameFrameWork_Godot/CodeEdit/custom_syntax_highlighter.gd")


func _ready():
	self.code_completion_prefixes = PackedStringArray(
		["p"],
	)
	
	# 设置 Gutter 相关属性
	setup_gutters()
	setup_code_run()
	
	# 设置语法高亮
	syntax_highlighting()
	
	# 连接信号到函数
	self.text_changed.connect(_on_text_changed)
	self.code_completion_requested.connect(_on_code_completion_requested)
	
	# 检查信号是否连接成功
	# print("信号连接状态: ", self.text_changed.get_connections())
	# 动态添加关键字颜色（如果需要的话）
	# self.syntax_highlighter.add






func _init():
	print("yan_code_edit _init")
	pass



func setup_code_run():
	"""
	设置代码执行按钮
	"""
	self.code_run_button.pressed.connect(func():
		code_run(self, self.output_label.label)
	)

	
func setup_gutters():
	"""
	设置CodeEdit的各种参数
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
	if self.text == "p":
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print", "print()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_debug", "print_debug()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_verbose", "print_verbose()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_warning", "print_warning()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_error", "print_error()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_fatal", "print_fatal()")
		self.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_script", "print_script()")
		self.update_code_completion_options(false)



func syntax_highlighting():
	"""
	设置代码高亮
	"""
	# 创建并设置自定义语法高亮器
	var highlighter = CustomSyntaxHighlighter.new()
	self.syntax_highlighter = highlighter




func code_run(input: TextEdit, output: Label):
	"""
	执行用户输入的代码
	"""
	# 获取用户输入的代码字符串
	var user_code = input.text
	
	output.text = ""
	# 检查用户输入是否为空
	if user_code.is_empty():
		output.text = "请输入代码！"
		return
	
	# 创建动态脚本
	var script = GDScript.new()
	

	var full_code = """
extends RefCounted
var dialog_system = null

%s
""" % user_code
	
	# 设置脚本源代码
	script.set_source_code(full_code)
	
	# 重新加载脚本（检查是否有编译错误）
	var reload_err: Error = script.reload()
	if reload_err != OK:
		var err_text := error_string(reload_err)
		var parts := []
		parts.append("编译失败：%s (错误码=%s)" % [err_text, str(reload_err)])
		output.text = "\n".join(parts)
		return
	else:
		print("代码编译成功")
	
	# 创建实例并执行
	var instance = script.new()

	if dialog_system != null:
		instance.set("dialog_system", dialog_system)


	# 执行用户代码
	if instance.has_method("test"):
		var result = instance.test()
		output.text += str(result)
		dialog_system.speak(str(result))
	else:
		dialog_system.speak("代码执行失败！看看是不是把函数名写错了哦~一定要写test") 
		print("用户代码执行失败！")

	if "a" in instance:
		var result2 = instance.a
		dialog_system.speak("代码执行成功啦！\n好厉害！") 
		print("用户代码执行结果: ", result2)
	else:
		dialog_system.speak("代码执行失败！没有定义a是无法执行的哦~~")
		print("用户代码执行失败！")


# 使用示例：
# 在代码编辑器中输入以下代码来修改对话框内容：
#
# func test():
#     dialog_label.text = "Hello from dynamic code!"
#     return "对话框已更新"
#
# 或者检查节点是否存在：
# func test():
#     if dialog_label:
#         dialog_label.text = "test"
#         return "对话框内容已修改为: test"
#     else:
#         return "未找到对话框节点"
