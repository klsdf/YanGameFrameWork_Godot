class_name YanUtil
extends RefCounted

"""
工具类，提供各种静态方法
"""


func find_local_node_by_name(root: Node, target_name: String) -> Node:
	"""递归遍历某一个节点的所有子节点，查找指定名称的节点，返回找到的节点，如果没找到返回null"""
	if root.name == target_name:
		return root
	
	# 遍历所有子节点
	for child in root.get_children():
		var result = find_local_node_by_name(child, target_name)
		if result:
			return result
	
	return null



# 通过节点名称查找节点
func find_global_node_by_name(node: Node, node_name: String) -> Node:
	"""
	通过节点名称查找节点
	参数：
		node: Node 使用这个函数的节点
		node_name: String 希望查找的节点名称
	返回：
		Node 找到的节点，如果没找到返回null
	"""
	# 安全检查：确保节点已经初始化并且可以访问场景树
	if not node.is_inside_tree():
		print("错误：节点还没有完全初始化，无法访问场景树")
		return null
	
	var tree = node.get_tree()
	if not tree:
		print("错误：无法获取场景树")
		return null
	
	var current_scene = tree.current_scene
	if not current_scene:
		print("错误：当前场景为空")
		return null
	
	print("当前场景名称：", current_scene.name)
	print("当前场景类名：", current_scene.get_class())
	
	# 通过节点名称查找
	var found_node = current_scene.find_child(node_name, true, false)
	
	if found_node:
		print("成功找到节点：", found_node.name)
		return found_node
	else:
		print("未找到节点：", node_name)
		# 打印当前场景的所有节点名称，帮助调试
		print("当前场景节点：")
		_print_node_tree(current_scene, 0)
		return null

# 辅助函数：打印节点树结构
func _print_node_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent + "- " + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		_print_node_tree(child, depth + 1)
