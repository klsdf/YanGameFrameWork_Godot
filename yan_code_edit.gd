class_name YanCodeEdit


extends CodeEdit


@export var output_label:Label
@export var code_run_button:Button
@export var lsp_host:String = "127.0.0.1"
@export var lsp_port:int = 6005

# 预加载本地 GDScript 语言服务器客户端
const YanGDScriptLSPClient = preload("res://YanGameFrameWork_Godot/yan_gdscript_lsp_client.gd")


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
	# print("信号连接状态: ", self.text_changed.get_connections())



func setup_code_run():
	"""
	设置代码执行按钮
	"""
	self.code_run_button.pressed.connect(func():
		code_run(self,self.output_label)
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
	"""
	执行用户输入的代码
	"""
	# 获取用户输入的代码字符串
	var user_code = input.text
	
	# 优先尝试用本地语言服务器做静态诊断（编辑器运行时有效）
	var lsp := YanGDScriptLSPClient.new()
	var lsp_diags := lsp.analyze_code(user_code, lsp_host, lsp_port)
	if lsp_diags.size() > 0:
		var lines: PackedStringArray = []
		lines.append("语言服务器诊断：")
		for d in lsp_diags:
			lines.append("第 %d 行，第 %d 列：%s" % [int(d.line), int(d.col), str(d.message)])
		output.text = "\n".join(lines)
		return
	elif lsp_diags.size() == 0:
		# LSP 可用但没有诊断，继续执行
		print("LSP 诊断完成，无错误，继续执行...")

	# 检查用户输入是否为空
	if user_code.is_empty():
		output.text = "请输入代码！"
		return
	
	# 创建动态脚本
	var script = GDScript.new()
	
	
	var full_code = """
extends RefCounted
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
		parts.append("提示：LSP 诊断不可用时，使用编译错误检测")
		output.text = "\n".join(parts)
		return
	else:
		print("代码编译成功")
	
	#创建实例并执行
	var instance = script.new()
	
	# 执行用户代码
	var result = instance.test()
	var result2 = instance.a
	output.text = "代码执行成功！\n结果: " + str(result) + "\n" + str(result2)
	print("用户代码执行结果: ", result)
	print("用户代码执行结果: ", result2)

var a = 1
func test():
	return "Hello from dynamic code!"


# 占位：如需高级静态分析，请在 Editor 插件或外部工具中实现
