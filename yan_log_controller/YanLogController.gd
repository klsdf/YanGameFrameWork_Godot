class_name YanLogController
extends RefCounted

## 简化的日志控制器
## 只有一个按钮和一个输出标签，点击按钮读取日志内容

## 日志文件路径配置
var _log_file_path: String
var log_file_path: String:
	get:
		if _log_file_path.is_empty():
			# 动态构建日志文件路径
			var user_data_dir = OS.get_user_data_dir()  # 获取用户数据目录
			_log_file_path = user_data_dir.path_join("logs").path_join("godot.log")
		return _log_file_path

# "C:/Users/17966/AppData/Roaming/Godot/app_userdata/godot cpp template/logs/godot.log"
func clear_log_files()->void:
	"""清空日志文件"""
	# 直接清空指定的日志文件
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if not file:
		print("错误：无法访问日志文件: " + log_file_path)
		return
	file.close()
	print("日志文件已清空")

func read_log_files()->String:
	"""读取日志文件内容"""
	print("正在读取日志文件...")
	
	# 直接读取指定的日志文件
	var file = FileAccess.open(log_file_path, FileAccess.READ)
	if not file:
		print("错误：无法访问日志文件: " + log_file_path)
		return ""
	
	# 读取文件内容并应用筛选规则
	var filtered_content = _apply_log_filter_rules(file)
	file.close()
	return filtered_content

## 应用日志筛选规则
func _apply_log_filter_rules(file: FileAccess) -> String:
	"""应用日志筛选规则，返回过滤后的内容"""
	var filtered_content = ""
	var is_inside_execution_block = false  # 是否在代码执行块内
	
	while not file.eof_reached():
		var line = file.get_line()
		
		# 规则1: 跳过以"yan_debug:"开头的行
		if line.begins_with("yan_debug:"):
			# 检查是否是开始执行代码的标记
			if "开始执行代码" in line:
				is_inside_execution_block = true
				continue
			# 检查是否是代码执行完成的标记
			elif "代码执行完成" in line:
				is_inside_execution_block = false
				continue
			# 其他yan_debug行直接跳过
			continue
		
		# 规则2: 只显示在代码执行块内的内容
		if is_inside_execution_block:
			filtered_content += line + "\n"
	
	return filtered_content

				
