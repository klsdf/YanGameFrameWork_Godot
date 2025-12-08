extends Node

## 存档管理器
## 支持自定义存档结构，可以注册不同的数据保存器/加载器
## 使用方式：
##   YanGF.Save.save_game(1, "key", value)  # 保存到存档槽1
##   YanGF.Save.load_game(1, "key")  # 从存档槽1加载

class_name YanSaveManager

## 存档路径前缀
const SAVE_DIR = "user://saves"
const MAX_SAVE_FILE_SLOT = 99

var save_file_slot: int = 0


func get_save_file_path() -> String:
	return SAVE_DIR + "/save_data_" + str(save_file_slot) + ".json"


func get_save_directory_path() -> String:
	"""获取存档目录的实际路径（绝对路径）"""
	# 将 user://saves 转换为绝对路径
	var save_dir_absolute = ProjectSettings.globalize_path(SAVE_DIR)
	return save_dir_absolute



func change_save_file_slot(slot: int) -> void:
	if slot > MAX_SAVE_FILE_SLOT:
		slot = MAX_SAVE_FILE_SLOT
		print("[YanSaveManager] 存档槽位超出最大值，已重置为最大值")
	if slot < 0:
		slot = 0
		print("[YanSaveManager] 存档槽位超出最小值，已重置为0")
	save_file_slot = slot
	print("[YanSaveManager] 存档槽位已切换到: %d" % save_file_slot)

func open_save_directory() -> void:
	"""打开存档目录（在文件管理器中）"""
	var save_dir = get_save_directory_path()
	
	# 确保目录存在
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.open(SAVE_DIR).make_dir_recursive(".")
	
	# 尝试打开目录
	var error = OS.shell_open(save_dir)
	if error != OK:
		push_error("[YanSaveManager] 无法打开存档目录: %s (错误码: %d)" % [save_dir, error])
		print("[YanSaveManager] 存档目录路径: %s" % save_dir)
	else:
		print("[YanSaveManager] 已打开存档目录: %s" % save_dir)



class SaveMetaData:
	var save_time: String = ""
	var save_slot: int = 0
	var save_file_path: String = ""
	var version: String = "1.0.0"
	func _init() -> void:
		save_time = Time.get_datetime_string_from_system()
		save_slot = 0
		save_file_path = ""
		version = "1.0.0"



func _check_and_create_save_file() -> void:
	"""创建存档文件（如果不存在）"""
	var save_file_path = get_save_file_path()
	
	# 确保存档目录存在
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(SAVE_DIR)):
		DirAccess.open(SAVE_DIR).make_dir_recursive(".")
		print("[YanSaveManager] 创建存档目录: %s" % SAVE_DIR)
	
	# 如果文件不存在，创建空文件
	if not FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.WRITE)
		if file:
			file.store_string("{}")  # 创建空的 JSON 对象
			file.close()
			print("[YanSaveManager] 创建存档文件: %s" % save_file_path)
		else:
			push_error("[YanSaveManager] 无法创建存档文件: %s" % save_file_path)



func _serialize_value(value: Variant) -> Variant:
	"""序列化值，将对象转换为可 JSON 序列化的格式"""
	if value == null:
		return null
	
	# 如果是数组
	if value is Array:
		var array = value as Array
		var serialized_array = []
		for item in array:
			serialized_array.append(_serialize_value(item))
		return serialized_array
	
	# 如果是字典
	if value is Dictionary:
		var dict = value as Dictionary
		var serialized_dict = {}
		for dict_key in dict:
			serialized_dict[dict_key] = _serialize_value(dict[dict_key])
		return serialized_dict
	
	# 如果是对象（RefCounted 或其他对象）
	if typeof(value) == TYPE_OBJECT:
		var obj = value
		var type_name = ""
		
		# 尝试获取类名
		if obj.get_script():
			var script = obj.get_script()
			if script.has_method("get_global_name"):
				type_name = script.get_global_name()
			else:
				# 从脚本路径推断类名
				var script_path = script.resource_path
				type_name = script_path.get_file().get_basename().replace("_", "").capitalize()
		
		# 如果还是获取不到，尝试使用 get_class()
		if type_name.is_empty():
			type_name = obj.get_class()
		
		var obj_dict = {
			"_type": type_name,
			"_data": {}
		}
		
		# 获取对象的所有属性
		var property_list = obj.get_property_list()
		for property in property_list:
			var prop_name = property.name
			# 跳过内部属性（以 _ 开头的）
			if prop_name.begins_with("_"):
				continue
			# 跳过方法
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
				continue
			
			if obj.get(prop_name) != null:
				obj_dict["_data"][prop_name] = _serialize_value(obj.get(prop_name))
		
		return obj_dict
	
	# 基本类型直接返回
	return value


func _deserialize_value(value: Variant) -> Variant:
	"""反序列化值，从 JSON 数据重建对象"""
	if value == null:
		return null
	
	# 如果是数组
	if value is Array:
		var array = value as Array
		var deserialized_array = []
		for item in array:
			deserialized_array.append(_deserialize_value(item))
		return deserialized_array
	
	# 如果是字典
	if value is Dictionary:
		var dict = value as Dictionary
		
		# 检查是否是序列化的对象（包含 _type 和 _data）
		if dict.has("_type") and dict.has("_data"):
			var type_name = dict["_type"] as String
			if type_name.is_empty():
				return null
			
			# 尝试通过 class_name 加载类（使用 get_script() 和 new()）
			# 首先尝试直接通过类型名创建（适用于 class_name 定义的类）
			var obj = null
			
			# 尝试通过脚本路径加载
			# 将类名转换为可能的脚本路径（例如 HotSearchEntry -> hot_search_entry.gd）
			var snake_case_name = type_name.to_snake_case()
			
			var script_paths = [
				"res://scripts/data_structs/" + snake_case_name + ".gd",
				"res://configs/story_config/" + snake_case_name + ".gd"
			]
			
			for script_path in script_paths:
				if ResourceLoader.exists(script_path):
					var script = load(script_path) as GDScript
					if script != null:
						obj = script.new()
						break
			
			# 如果还是找不到，输出错误信息
			if obj == null:
				push_error("[YanSaveManager] 无法创建类型实例: %s，请确保脚本路径正确。尝试的路径: %s" % [type_name, str(script_paths)])
				return null
			
			# 恢复属性
			var data = dict["_data"] as Dictionary
			for prop_name in data:
				if obj.has(prop_name):
					obj.set(prop_name, _deserialize_value(data[prop_name]))
			
			return obj
		else:
			# 普通字典，递归处理值
			var deserialized_dict = {}
			for dict_key in dict:
				deserialized_dict[dict_key] = _deserialize_value(dict[dict_key])
			return deserialized_dict
	
	# 基本类型直接返回
	return value


func save_game( key, value) -> void:
	"""保存游戏数据到指定槽位，支持对象序列化"""
	# 确保存档文件存在
	_check_and_create_save_file()
	
	var save_file_path = get_save_file_path()
	
	# 读取现有数据（如果存在）
	var save_data: Dictionary = {}
	
	var read_file = FileAccess.open(save_file_path, FileAccess.READ)
	if read_file:
		var existing_json = read_file.get_as_text()
		read_file.close()
		var json = JSON.new()
		var parse_result = json.parse(existing_json)
		if parse_result == OK:
			save_data = json.data as Dictionary
	
	# 序列化值（如果是对象则转换为字典）
	var serialized_value = _serialize_value(value)
	
	# 更新或添加新的 key-value
	save_data[key] = serialized_value
	
	# 更新或创建存档元数据
	var meta_data: SaveMetaData
	if save_data.has("_meta_data"):
		var meta_serialized = save_data["_meta_data"]
		meta_data = _deserialize_value(meta_serialized) as SaveMetaData
		if meta_data == null:
			meta_data = SaveMetaData.new()
	else:
		meta_data = SaveMetaData.new()
	
	# 更新元数据
	meta_data.save_time = Time.get_datetime_string_from_system()
	meta_data.save_slot = save_file_slot
	meta_data.save_file_path = save_file_path
	meta_data.version = "1.0.0"
	
	# 序列化并保存元数据
	save_data["_meta_data"] = _serialize_value(meta_data)
	
	# 保存到文件
	var json_string = JSON.stringify(save_data)
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("[YanSaveManager] 游戏已保存到槽位 %d，键: %s" % [save_file_slot, str(key)])
	else:
		push_error("[YanSaveManager] 无法打开文件进行写入: %s" % save_file_path)


func load_game(key: String, default_value: Variant = null) -> Variant:
	"""从指定槽位加载游戏数据，返回对应 key 的值，支持对象反序列化
	@param key: 要加载的键名
	@param default_value: 当键不存在时使用的默认值。如果提供了默认值，会自动保存到存档中
	@return: 加载的值，如果键不存在且未提供默认值则返回 null
	"""
	_check_and_create_save_file()
	
	var save_file_path = get_save_file_path()
	
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if not file:
		# 如果提供了默认值，使用默认值并保存（这是正常的初始化过程）
		if default_value != null:
			print("[YanSaveManager] 存档文件不存在，使用默认值并创建存档，键: %s" % key)
			save_game(key, default_value)
			return default_value
		# 如果没有提供默认值，这才是真正的错误
		push_error("[YanSaveManager] 无法打开存档文件: %s" % save_file_path)
		return null
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		# 如果提供了默认值，使用默认值并保存（尝试修复损坏的存档）
		if default_value != null:
			print("[YanSaveManager] JSON 解析失败，使用默认值并修复存档，键: %s" % key)
			save_game(key, default_value)
			return default_value
		# 如果没有提供默认值，这才是真正的错误
		push_error("[YanSaveManager] JSON 解析失败: %s" % save_file_path)
		return null
	
	var save_data = json.data as Dictionary
	if not save_data.has(key):
		# 如果提供了默认值，使用默认值并保存到存档
		if default_value != null:
			print("[YanSaveManager] 存档中不存在键: %s，使用默认值并保存" % key)
			save_game(key, default_value)
			return default_value
		else:
			push_warning("[YanSaveManager] 存档中不存在键: %s" % key)
			return null
	
	var serialized_value = save_data[key]
	
	# 反序列化值（如果是对象则重建）
	var value = _deserialize_value(serialized_value)
	
	print("[YanSaveManager] 从槽位 %d 加载键 %s 的值" % [save_file_slot, key])
	return value


func get_save_meta_data() -> SaveMetaData:
	"""获取指定槽位的存档元数据"""
	if not FileAccess.file_exists(get_save_file_path()):
		return null
	
	var meta_data_serialized = load_game("_meta_data")
	if meta_data_serialized == null:
		return null
	
	return meta_data_serialized as SaveMetaData
