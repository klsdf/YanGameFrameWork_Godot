class_name TestRealErrorInterception
extends Node

@export var button: Button
# 测试真正的错误拦截功能
# 这个脚本演示如何拦截 Godot 引擎的所有错误和警告

var yan_class: YanClass


func _ready():
	print("开始测试真正的错误拦截功能...")
	
	# 创建 YanClass 实例
	yan_class = YanClass.new()
	
	# 启用错误拦截
	yan_class.enable_error_interception()
	
	# 测试脚本验证
	test_script_validation()


func test_script_validation():
	print("测试脚本验证  开始!!!")
	
	# 测试有效的代码
	var valid_code = """
extends Node

func _ready():
	print("Hello World")
"""
	
	var result = yan_class.validate_script_syntax(valid_code)
	print("有效代码验证结果: ", result)
	
	# 测试无效的代码
	var invalid_code = """
extends Node

func _ready():
	print("Hello World")
	# 缺少右括号
"""
	
	result = yan_class.validate_script_syntax(invalid_code)
	print("无效代码验证结果: ", result)
	
	# 测试空代码
	result = yan_class.validate_script_syntax("")
	print("空代码验证结果: ", result)
	
	print("=== 测试脚本验证 ===")
