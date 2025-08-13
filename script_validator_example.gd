extends Node

## 脚本验证器示例
## 展示如何使用YanClass进行脚本编译错误检测和语法验证，包括错误拦截

@onready var yan_class: YanClass = YanClass.new()


@export var button: Button

func _ready():
	print("脚本验证器示例启动")
	
	# 启用错误拦截
	yan_class.enable_error_interception()
	
	# 测试各种代码验证场景
	# test_valid_code()
	# test_invalid_syntax()
	# test_compilation_errors()
	# test_script_validation()
	
	# 等待一帧，让错误有时间被拦截
	await get_tree().process_frame
	
	# 显示拦截到的错误信息
	display_intercepted_errors()
	button.pressed.connect(display_intercepted_errors)

## 测试有效代码
func test_valid_code():
	print("\n=== 测试有效代码 ===")
	
	var valid_code = """
extends Node

func _ready():
	print("Hello World"
	
func add_numbers(a: int, b: int) -> int:
	return a + b
"""
	
	var result = yan_class.validate_script_syntax(valid_code)
	print_validation_result("有效代码测试", result)

## 测试无效语法
func test_invalid_syntax():
	print("\n=== 测试无效语法 ===")
	
	var invalid_code = """
extends Node

func _ready():
	print("Hello World"
	# 缺少右括号
	
func add_numbers(a: int, b: int) -> int:
	return a + b
"""
	
	var result = yan_class.validate_script_syntax(invalid_code)
	print_validation_result("无效语法测试", result)

## 测试编译错误
func test_compilation_errors():
	print("\n=== 测试编译错误 ===")
	
	var compilation_error_code = """
extends Node

func _ready():
	var undefined_variable = some_undefined_function()
	print(undefined_variable)
"""
	
	var result = yan_class.validate_script_syntax(compilation_error_code)
	print_validation_result("编译错误测试", result)

## 测试脚本对象验证
func test_script_validation():
	print("\n=== 测试脚本对象验证 ===")
	
	# 创建一个测试脚本
	var test_script = GDScript.new()
	test_script.source_code = """
extends Node

func _ready():
	print("测试脚本")
"""
	
	# 获取脚本错误信息
	var error_result = yan_class.get_script_errors(test_script)
	print_validation_result("脚本错误检测", error_result)
	
	# 获取编译状态
	var status_result = yan_class.get_script_compilation_status(test_script)
	print_validation_result("编译状态检测", status_result)

## 显示拦截到的错误信息
func display_intercepted_errors():
	print("\n=== 拦截到的错误信息 ===")
	
	# 获取错误摘要
	var summary = yan_class.get_error_summary()
	print("错误数量: ", summary["error_count"])
	print("警告数量: ", summary["warning_count"])
	print("是否有错误: ", summary["has_errors"])
	
	# 显示最近的错误
	if summary.has("recent_errors"):
		var recent_errors = summary["recent_errors"]
		if recent_errors.size() > 0:
			print("\n最近的错误:")
			for i in range(recent_errors.size()):
				print("  %s: %s" % [i + 1, recent_errors[i]])
	
	# 显示最近的警告
	if summary.has("recent_warnings"):
		var recent_warnings = summary["recent_warnings"]
		if recent_warnings.size() > 0:
			print("\n最近的警告:")
			for i in range(recent_warnings.size()):
				print("  %s: %s" % [i + 1, recent_warnings[i]])
	
	# 获取所有拦截的错误
	var all_errors = yan_class.get_intercepted_errors()
	if all_errors.size() > 0:
		print("\n所有拦截的错误:")
		for i in range(all_errors.size()):
			print("  %s: %s" % [i + 1, all_errors[i]])
	
	# 获取所有拦截的警告
	var all_warnings = yan_class.get_intercepted_warnings()
	if all_warnings.size() > 0:
		print("\n所有拦截的警告:")
		for i in range(all_warnings.size()):
			print("  %s: %s" % [i + 1, all_warnings[i]])

## 打印验证结果
func print_validation_result(test_name: String, result: Dictionary):
	print("--- %s ---" % test_name)
	
	if result.has("valid"):
		print("有效: %s" % result["valid"])
	
	if result.has("error_code"):
		print("错误码: %s" % result["error_code"])
	
	if result.has("error"):
		print("错误: %s" % result["error"])
	
	if result.has("error_type"):
		print("错误类型: %s" % result["error_type"])
	
	if result.has("suggestion"):
		print("建议: %s" % result["suggestion"])
	
	if result.has("source_length"):
		print("源代码长度: %s" % result["source_length"])
	
	if result.has("source_lines"):
		print("源代码行数: %s" % result["source_lines"])
	
	if result.has("compilation_success"):
		print("编译成功: %s" % result["compilation_success"])
	
	print("")

## 实时验证用户输入的代码（带错误拦截）
func validate_user_code_with_error_interception(code: String) -> Dictionary:
	"""
	验证用户输入的代码并返回详细结果，包括拦截到的错误
	@param code 用户输入的代码
	@return 验证结果字典
	"""
	# 清空之前的错误
	yan_class.clear_intercepted_messages()
	
	# 验证代码
	var result = yan_class.validate_script_syntax(code)
	
	# 等待一帧，让错误有时间被拦截
	await get_tree().process_frame
	
	# 获取拦截到的错误
	var errors = yan_class.get_intercepted_errors()
	var warnings = yan_class.get_intercepted_warnings()
	
	# 构建完整的错误报告
	var error_report = {
		"valid": result["valid"],
		"validation_result": result,
		"intercepted_errors": errors,
		"intercepted_warnings": warnings,
		"error_count": errors.size(),
		"warning_count": warnings.size(),
		"has_intercepted_errors": errors.size() > 0
	}
	
	# 添加用户友好的错误信息
	if not result["valid"]:
		var error_message = "代码存在以下问题：%s" % result["error_type"]
		
		if errors.size() > 0:
			error_message += "\n\n拦截到的错误信息："
			for i in range(min(3, errors.size())):  # 只显示前3个错误
				error_message += "\n%s. %s" % [i + 1, errors[i]]
		
		if result.has("suggestion"):
			error_message += "\n\n建议：%s" % result["suggestion"]
		
		error_report["user_message"] = error_message
	else:
		error_report["user_message"] = "代码语法正确！可以运行。"
		
		if warnings.size() > 0:
			error_report["user_message"] += "\n\n注意：有 %s 个警告" % warnings.size()
	
	return error_report

## 获取脚本的详细编译信息
func get_detailed_script_info(script: Script) -> Dictionary:
	"""
	获取脚本的详细编译信息
	@param script 要检查的脚本对象
	@return 详细信息字典
	"""
	var error_info = yan_class.get_script_errors(script)
	var status_info = yan_class.get_script_compilation_status(script)
	
	# 合并信息
	var detailed_info = {}
	detailed_info.merge(error_info)
	detailed_info.merge(status_info)
	
	# 添加总结信息
	if detailed_info.has("valid") and detailed_info["valid"]:
		detailed_info["summary"] = "脚本编译成功，可以正常使用"
	else:
		detailed_info["summary"] = "脚本存在问题，需要修复后才能使用"
	
	return detailed_info

## 错误监控系统
func start_error_monitoring():
	"""
	启动错误监控系统，定期检查是否有新错误
	"""
	print("启动错误监控系统...")
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5  # 每0.5秒检查一次
	timer.timeout.connect(_on_error_check_timer_timeout)
	timer.start()

func _on_error_check_timer_timeout():
	"""
	定时器超时时检查是否有新错误
	"""
	if yan_class.has_new_errors():
		var latest_error = yan_class.get_latest_error()
		var error_count = yan_class.get_error_count()
		
		print("检测到新错误！总数: %s" % error_count)
		print("最新错误: %s" % latest_error)
		
		# 可以在这里更新UI或发送信号
		error_detected.emit(latest_error, error_count)

## 信号定义
signal error_detected(error_message: String, error_count: int)

## 清理资源
func cleanup():
	"""
	清理错误拦截系统
	"""
	yan_class.disable_error_interception()
	yan_class.clear_intercepted_messages()
	print("错误拦截系统已清理")
