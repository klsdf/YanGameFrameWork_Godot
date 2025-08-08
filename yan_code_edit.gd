class_name YanCodeEdit
extends CodeEdit

@export var output_label: Label
@export var code_run_button: Button
@export var lsp_host: String = "127.0.0.1"
@export var lsp_port: int = 6005
	# 获取场景树中的节点引用
@export var dialog_label: Label

# 预加载DialogSystem类

@export var dialog_system: DialogSystem


@export var dic :Dictionary[String, Color]


# 预加载本地 GDScript 语言服务器客户端
const YanGDScriptLSPClient = preload("res://YanGameFrameWork_Godot/yan_gdscript_lsp_client.gd")
# 预加载自定义语法高亮器
const CustomSyntaxHighlighter = preload("res://YanGameFrameWork_Godot/custom_syntax_highlighter.gd")


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
		code_run(self, self.output_label)
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

# 预定义的节点引用
var dialog_label = null
var dialogue_system = null

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
	
	# 设置节点引用
	if dialog_label:
		instance.set("dialog_label", dialog_label)


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
		dialog_system.speak("代码执行成功啦！\n好厉害你！") 
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
