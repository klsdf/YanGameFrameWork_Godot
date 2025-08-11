class_name CodeCompletionConfig
extends RefCounted

"""
代码补全配置文件
用于存储各种代码补全选项的配置数据
"""

# 获取指定前缀的补全选项
static func get_completion_options(current_word: String, code_edit: YanCodeEdit) -> void:
	# 打印相关函数
	if current_word.begins_with("p"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print", "print()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_debug", "print_debug()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_verbose", "print_verbose()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_warning", "print_warning()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_error", "print_error()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_fatal", "print_fatal()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "print_script", "print_script()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "push_error", "push_error()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "push_warning", "push_warning()")
	
	# 函数定义
	if current_word.begins_with("f"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "func", "func")

	
	# 变量声明
	if current_word.begins_with("v"):
		code_edit.add_code_completion_option(CodeEdit.KIND_VARIABLE, "var", "var")

	
	# 常量声明
	if current_word.begins_with("c"):
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "const", "const")
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "class_name", "class_name")
	
	# 控制流语句
	if current_word.begins_with("i"):

		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "if", "if condition:")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "else", "else:")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "in", "in")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "elif", "elif condition:")
	
	# 循环语句
	if current_word.begins_with("f"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "for", "for")
	
	if current_word.begins_with("w"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "while", "while")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "while", "while condition:")
	
	# 返回和中断
	if current_word.begins_with("r"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "return", "return")
	
	if current_word.begins_with("b"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "break", "break")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "break", "break")
	
	if current_word.begins_with("c"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "continue", "continue")
	
	# 类型相关
	if current_word.begins_with("t"):
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "true", "true")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "typeof", "typeof()")
	
	if current_word.begins_with("f"):
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "false", "false")
	
	if current_word.begins_with("n"):
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "null", "null")
	
	# 节点相关
	if current_word.begins_with("g"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "get_node", "get_node()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "get_parent", "get_parent()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "get_child", "get_child()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "get_children", "get_children()")
	
	if current_word.begins_with("a"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "add_child", "add_child()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "await", "await")
	
	if current_word.begins_with("r"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "remove_child", "remove_child()")
	
	# 信号相关
	if current_word.begins_with("s"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "signal", "signal")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "signal", "signal my_signal")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "connect", "connect()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "emit_signal", "emit_signal()")
	
	# 数学和工具函数
	if current_word.begins_with("m"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "max", "max()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "min", "min()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "move_toward", "move_toward()")
	
	if current_word.begins_with("r"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "randf", "randf()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "randi", "randi()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "range", "range()")
	
	# 字符串和数组操作
	if current_word.begins_with("s"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "str", "str()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "split", "split()")
	
	if current_word.begins_with("j"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "join", "join()")
	
	# 类型转换
	if current_word.begins_with("i"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "int", "int()")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "is_instance_valid", "is_instance_valid()")
	
	if current_word.begins_with("f"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "float", "float()")
	
	# 其他常用关键词
	if current_word.begins_with("e"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "extends", "extends")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "export", "export")
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "enum", "enum")
	
	if current_word.begins_with("o"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "onready", "onready")
	
	if current_word.begins_with("m"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "match", "match")
	
	if current_word.begins_with("a"):
		code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "assert", "assert()")
	
	# 内置类型
	if current_word.begins_with("V"):
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Vector2", "Vector2")
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Vector3", "Vector3")
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Vector2i", "Vector2i")
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Vector3i", "Vector3i")
	
	if current_word.begins_with("C"):
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Color", "Color")
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Curve", "Curve")
	
	if current_word.begins_with("R"):
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Rect2", "Rect2")
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Rect2i", "Rect2i")
	
	if current_word.begins_with("T"):
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Transform2D", "Transform2D")
		code_edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "Transform3D", "Transform3D")
	

