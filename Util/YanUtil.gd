class_name YanUtil
extends RefCounted

"""
工具类，提供各种静态方法
"""

var _scene_path_cache: Dictionary = {}
var _packed_scene_cache: Dictionary = {}

## 通过递归的方式查找场景文件，默认从根目录的scenes文件夹开始查找
## @param scene_name: String 希望查找的场景名称
## @return Node 找到的场景，如果没找到返回null
func load_scene(scene_name: String) -> Node:
	# 允许传入不带后缀的名称，例如 "Main"；也允许传入带后缀或路径
	var cache_key := scene_name.get_file().get_basename()
	
	# 优先使用已缓存的 PackedScene
	if _packed_scene_cache.has(cache_key):
		var cached_scene := _packed_scene_cache[cache_key] as PackedScene
		if cached_scene:
			return cached_scene.instantiate()
	
	# 其次使用已缓存的路径
	if _scene_path_cache.has(cache_key):
		var cached_path: String = _scene_path_cache[cache_key]
		var cached_res := ResourceLoader.load(cached_path)
		if cached_res is PackedScene:
			_packed_scene_cache[cache_key] = cached_res
			return (cached_res as PackedScene).instantiate()
	
	var start_paths := ["res://scenes"]
	for start_path in start_paths:
		if not DirAccess.dir_exists_absolute(start_path):
			continue
		var found_path := _find_scene_path(scene_name, start_path)
		if found_path != "":
			var res := ResourceLoader.load(found_path)
			if res is PackedScene:
				# 写入缓存
				_scene_path_cache[cache_key] = found_path
				_packed_scene_cache[cache_key] = res
				return (res as PackedScene).instantiate()
			else:
				print("找到资源但不是场景：", found_path)
				return null
	
	print("YanUtil: 未找到场景：", scene_name)
	return null


func _find_scene_path(scene_name: String, directory: String) -> String:
	# 规范化目标名用于比较（不带扩展名）
	var target_basename := scene_name.get_file().get_basename()
	
	# 检查当前目录的文件
	for file_name in DirAccess.get_files_at(directory):
		if file_name.begins_with("."):
			continue
		if not (file_name.ends_with(".tscn") or file_name.ends_with(".scn")):
			continue
		var base := file_name.get_basename()
		if base == target_basename or file_name == scene_name or base == scene_name.get_basename():
			return directory.rstrip("/") + "/" + file_name
	
	# 递归进入子目录
	for sub_dir in DirAccess.get_directories_at(directory):
		if sub_dir.begins_with(".") or sub_dir == ".import":
			continue
		var sub_path := directory.rstrip("/") + "/" + sub_dir
		var result := _find_scene_path(scene_name, sub_path)
		if result != "":
			return result
	
	return ""

## 通过节点名称查找节点（在某个节点中查找）
## @param root: Node 希望查找的节点
## @param target_name: String 希望查找的节点名称
## @return Node 找到的节点，如果没找到返回null
func find_local_node_by_name(node: Node, target_name: String) -> Node:
	var found = node.find_child(target_name, true, true)
	if not found:
		push_warning("[YanUtil] 未找到子节点: " + target_name + "（起点: " + node.name + "）")
		return null
	return found


# func find_local_node_by_name(root: Node, target_name: String) -> Node:
# 	if root.name == target_name:
# 		return root
	
# 	# 遍历所有子节点
# 	for child in root.get_children():
# 		var result = find_local_node_by_name(child, target_name)
# 		if result:
# 			return result
# 	return null


## 通过节点名称查找节点（在整个场景中查找）
## @param node_name: String 希望查找的节点名称
## @return Node 找到的节点，如果没找到返回null
func find_global_node_by_name(node_name: String) -> Node:

	# 获取场景树
	var main_loop = Engine.get_main_loop()
	if not main_loop is SceneTree:
		print("错误：无法获取场景树")
		return null
	
	var tree = main_loop as SceneTree
	var current_scene = tree.current_scene
	if not current_scene:
		print("错误：当前场景为空")
		return null
	
	# 通过节点名称查找
	var found_node = current_scene.find_child(node_name, true, false)
	
	if found_node:
		return found_node
	else:
		print("未找到节点：", node_name)
		# 打印当前场景的所有节点名称，帮助调试
		# print("当前场景节点：")
		# _print_node_tree(current_scene, 0)
		return null

# 辅助函数：打印节点树结构
func _print_node_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent + "- " + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		_print_node_tree(child, depth + 1)
