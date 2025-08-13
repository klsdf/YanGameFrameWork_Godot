class_name LogController
extends RefCounted

## 简化的日志控制器
## 只有一个按钮和一个输出标签，点击按钮读取日志内容

## 日志文件路径配置
var log_directory_path: String = "C:/Users/17966/AppData/Roaming/Godot/app_userdata/godot cpp template/logs"


func read_log_files()->String:
	"""读取日志文件内容"""
	print("正在读取日志文件...")
	
	# 检查日志目录是否存在
	var dir = DirAccess.open(log_directory_path)
	if not dir:
		print("错误：无法访问日志目录: " + log_directory_path)
		return ""
	
	# 获取所有日志文件
	var file_list = dir.get_files()
	
	for file_name in file_list:
		# 只处理godot.log文件
		if file_name == "godot.log":
			var full_path = log_directory_path.path_join(file_name)
			var file = FileAccess.open(full_path, FileAccess.READ)
			if file:
				# 读取文件内容并应用筛选规则
				var filtered_content = _apply_log_filter_rules(file)
				file.close()
				return filtered_content
	return ""

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

				
