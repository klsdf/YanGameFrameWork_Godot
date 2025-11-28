extends RefCounted

## CSV管理器
## 用于读写CSV文件
## 公有方法：
## CSVManager.load_csv("res://data.csv")
## CSVManager.load_csv_header("res://data.csv")
## CSVManager.save_csv(data, "res://data.csv")
## CSVManager.convert_to_objects(object_class, "res://data.csv")
## CSVManager.load_csv_as_dict("res://data.csv")
class_name YanCSVManager


class CSVData:
	var header: Array[Array]
	var content: Array[Array]
	func get_first_line() -> Array:
		return header[0]

## 读取CSV文件并返回二维数组
## @param file_path: CSV文件路径
## @param header_lines: 需要跳过的表头行数，默认0
## 注意！！！如果有表头，可以直接使用load_csv(xxx,1)，无需手动跳过

## @return: 返回Array[Array]，内层数组是每行的数据
## 示例: [["张三", "18"], ["李四", "20"]]
func load_csv(file_path: String, header_lines: int = 0) -> Array[Array]:
	var raw_data = _load_csv_raw(file_path, header_lines)
	return raw_data.content

## 读取CSV文件的表头（第一行）并返回一维数组
## @param file_path: CSV文件路径
## @return: 返回Array，包含第一行的所有列数据
## 示例: ["name", "age", "city"]
func load_csv_header(file_path: String) -> Array:
	var raw_data = _load_csv_raw(file_path, 1)
	if raw_data.header.is_empty():
		return []
	return raw_data.get_first_line()




## 将二维数组转换为CSV格式
## @param data: 二维数组，例如 [["name", "age"], ["张三", "18"]]
## @param file_path: 保存路径
## @param separator: 分隔符，默认是逗号
## @return: 成功返回true，失败返回false
func save_csv(data: Array, file_path: String) -> bool:
	var separator: String = ","
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("无法创建CSV文件: " + file_path)
		return false
	
	for row in data:
		var line = ""
		for i in range(row.size()):
			if i > 0:
				line += separator
			
			var value = str(row[i])
			# 如果值包含逗号或引号，需要用引号包裹
			if separator in value or '"' in value:
				value = '"' + value.replace('"', '""') + '"'
			line += value
		
		file.store_line(line)
	
	file.close()
	return true


## 从CSV创建字典（第0行作为表头，返回单个字典）
## @param file_path: CSV文件路径
## @param header_line_num: 表头有几行，默认0
## @return: 返回Dictionary，第0列作为key，对应行的其他列作为值（也是字典）
## 示例: {"张三": {"name": "张三", "age": "18"}, "李四": {"name": "李四", "age": "20"}}
func load_csv_as_dict(file_path: String, header_line_num: int = 0) -> Array[Dictionary]:
	# 读取所有数据（包括表头行）
	var raw_data = _load_csv_raw(file_path, header_line_num)
	var content = raw_data.content
	var true_header: Array = raw_data.get_first_line()
	
	if content.is_empty():
		return []
	

	
	# 将数据行转换为单个字典（第0列作为主key）
	var result: Array[Dictionary] = []

	for i in range(content.size()):
		var values = content[i]
		if values.size() == 0:
			continue
		# 创建该行的子字典，包含所有列
		var row_dict: Dictionary = {}
		for j in range(true_header.size()):
			var header = true_header[j]
			var value = values[j] if j < values.size() else ""
			row_dict[header] = value
		result.append(row_dict)
		
	return result

## 将CSV文件转换为对象数组（通过反射自动映射字段）
## @param object_class: 目标类（如 HotSearchEntry）
## @param file_path: CSV文件路径
## @param header_lines: 需要跳过的表头行数，默认1（第一行作为字段名）
## @return: 返回Array（普通数组，非类型化数组），包含转换后的对象实例
## 注意: 在GDScript中，不能直接使用 `as Array[Type]` 将普通Array转换为类型化数组。
##       如果需要类型化数组，请手动构建：
##       1. 先获取返回的Array
##       2. 声明类型化数组变量并初始化为空数组
##       3. 遍历返回的Array，将每个元素转换为目标类型后添加到类型化数组中
## 示例（正确用法）:
##   var result = YanGF.CSV.load_csv_as_objects(HotSearchEntry, "res://data.csv", 1)
##   var entries: Array[HotSearchEntry] = []
##   for item in result:
##       entries.append(item as HotSearchEntry)
##   print(entries[0].title)  # 访问对象属性
## 示例（错误用法，会导致类型错误）:
##   var entries: Array[HotSearchEntry] = YanGF.CSV.load_csv_as_objects(HotSearchEntry, "res://data.csv", 1) as Array[HotSearchEntry]  # ❌ 错误
func load_csv_as_objects(object_class, file_path: StringName, header_lines: int = 1) -> Array:
	var result: Array = []
	
	# 读取表头
	var headers = load_csv_header(file_path)
	if headers.is_empty():
		push_warning("无法读取CSV表头: " + file_path)
		return result
	
	# 读取数据行
	var rows = load_csv(file_path, header_lines)
	if rows.is_empty():
		return result
	
	# 创建临时实例以获取属性列表
	var temp_instance = object_class.new()
	var property_list = temp_instance.get_property_list()
	# RefCounted 类型会自动管理内存，不需要手动释放
	if temp_instance is Node:
		temp_instance.queue_free()
	else:
		temp_instance = null
	
	# 构建属性名到类型的映射
	var property_map: Dictionary = {}
	for prop in property_list:
		var prop_name = prop.name
		# 跳过内置属性
		if prop_name.begins_with("_") or prop_name in ["script", "owner"]:
			continue
		property_map[prop_name] = prop.type
	
	# 将每行数据转换为对象
	for row in rows:
		var instance = object_class.new()
		
		for i in range(headers.size()):
			if i >= row.size():
				continue
			
			var header = str(headers[i]).strip_edges()
			var value = str(row[i]).strip_edges()
			
			# 检查属性是否存在
			if not property_map.has(header):
				continue
			
			# 根据属性类型转换值
			var prop_type = property_map[header]
			var converted_value = _convert_value_by_type(value, prop_type)
			
			# 设置属性值
			instance.set(header, converted_value)
		
		# 添加实例（已经是正确的类型）
		result.append(instance)
	
	return result

## 内部方法：根据类型转换值
func _convert_value_by_type(value: String, type: int):
	var trimmed = value.strip_edges()
	
	# 空字符串处理
	if trimmed.is_empty():
		match type:
			TYPE_INT, TYPE_FLOAT:
				return 0
			TYPE_BOOL:
				return false
			_:
				return ""
	
	match type:
		TYPE_INT:
			return int(trimmed) if trimmed.is_valid_int() else 0
		TYPE_FLOAT:
			return float(trimmed) if trimmed.is_valid_float() else 0.0
		TYPE_BOOL:
			var lower = trimmed.to_lower()
			return lower == "true" or lower == "1"
		TYPE_STRING:
			return trimmed
		_:
			# 默认尝试智能转换
			if trimmed.is_valid_int():
				return int(trimmed)
			elif trimmed.is_valid_float():
				return float(trimmed)
			else:
				var lower = trimmed.to_lower()
				if lower == "true" or lower == "1":
					return true
				elif lower == "false" or lower == "0":
					return false
				return trimmed

## 内部方法：打开CSV文件（读取模式）
## 支持跨平台（包括Web导出）
## @return: 成功返回FileAccess对象，失败返回null
func _open_csv_file_read(file_path: String) -> FileAccess:
	# 首先检查文件是否存在
	if not FileAccess.file_exists(file_path):
		push_error("CSV文件不存在: " + file_path)
		push_error("当前平台: " + OS.get_name())
		push_error("提示：请确保CSV文件在导出预设的include_filter中")
		return null
	
	# 尝试打开文件
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("无法打开CSV文件: " + file_path)
		push_error("当前平台: " + OS.get_name())
		
		# Web平台特殊提示
		if OS.get_name() == "Web" or OS.get_name() == "HTML5":
			push_error("Web平台提示：")
			push_error("  1. 确保CSV文件在导出预设中被包含")
			push_error("  2. 检查export_presets.cfg中的include_filter设置")
			push_error("  3. 如果问题持续，考虑使用Resource类包装CSV数据")
		
		return null
	
	return file


## 内部方法：打开并读取CSV文件
func _load_csv_raw(file_path: String, header_lines_num: int = 0 ) -> CSVData:
	var result: CSVData = CSVData.new()
	result.header = []
	result.content = []
	
	var file = _open_csv_file_read(file_path)
	if file == null:
		return result
	

	
	# 如果需要包含表头，读取表头
	if header_lines_num > 0:
		for i in range(header_lines_num):
			var _header_line = _read_csv_line(file)
			if not _header_line.is_empty():
				var values = _split_csv_line(_header_line)
				result.header.append(values)
	
	# 逐行读取（支持多行字段）
	while not file.eof_reached():
		var line = _read_csv_line(file)
		if line.is_empty() and file.eof_reached():
			break
		if line.is_empty():
			continue
		
		# 分割每行数据
		var values = _split_csv_line(line)
		result.content.append(values)
	
	file.close()
	return result


## 内部方法：读取CSV行（支持多行字段，即引号内的换行符）
## 根据CSV标准，如果字段值包含换行符，字段必须用双引号括起来
## 此方法会读取完整的一行，包括引号内的换行符
func _read_csv_line(file: FileAccess) -> String:
	if file.eof_reached():
		return ""
	
	var result = ""
	var in_quotes = false
	var line = file.get_line()
	
	# 如果文件已结束且行为空，直接返回
	if line.is_empty() and file.eof_reached():
		return ""
	
	result = line
	
	# 检查是否在引号内（需要正确统计引号，忽略转义的引号）
	var i = 0
	while i < line.length():
		if line[i] == '"':
			# 检查是否是转义的引号（两个连续引号 ""）
			if i + 1 < line.length() and line[i + 1] == '"':
				# 这是转义的引号，跳过
				i += 2
				continue
			else:
				# 这是真正的引号，切换状态
				in_quotes = !in_quotes
		i += 1
	
	# 如果引号未闭合，说明字段值跨越多行，需要继续读取
	while in_quotes and not file.eof_reached():
		var next_line = file.get_line()
		result += "\n" + next_line
		
		# 重新检查引号状态
		i = 0
		while i < next_line.length():
			if next_line[i] == '"':
				# 检查是否是转义的引号
				if i + 1 < next_line.length() and next_line[i + 1] == '"':
					i += 2
					continue
				else:
					in_quotes = !in_quotes
			i += 1
	
	return result

## 内部方法：安全分割CSV行（处理引号内的逗号和换行符）
func _split_csv_line(line: String) -> Array:
	var result: Array = []
	var current = ""
	var separator: String = ","
	var in_quotes = false
	var field_started_with_quote = false
	
	var i = 0
	while i < line.length():
		var char_code = line[i]
		
		if char_code == '"':
			if not in_quotes:
				# 字段开始，遇到开始的引号
				in_quotes = true
				field_started_with_quote = true
			else:
				# 在引号内，检查是否是转义的引号（两个连续引号 ""）
				if i + 1 < line.length() and line[i + 1] == '"':
					# 转义的引号，添加一个引号到字段值中
					current += '"'
					i += 2  # 跳过两个引号
					continue
				else:
					# 结束引号
					in_quotes = false
		elif char_code == separator and not in_quotes:
			# 字段分隔符，且不在引号内
			result.append(current)
			current = ""
			field_started_with_quote = false
		else:
			# 普通字符，添加到当前字段
			current += char_code
		
		i += 1
	
	# 添加最后一个字段
	result.append(current)
	
	return result
