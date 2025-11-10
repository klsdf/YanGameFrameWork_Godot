class_name YanUtil
extends RefCounted

"""
工具类，提供各种静态方法
"""

## 通过节点名称查找节点（在某个节点中查找）
## @param root: Node 希望查找的节点
## @param target_name: String 希望查找的节点名称
## @return Node 找到的节点，如果没找到返回null
func find_local_node_by_name(root: Node, target_name: String) -> Node:
	# 如果 root 本身就是要找的节点，直接返回
	if root.name == target_name:
		return root
	# 使用 find_child 递归查找子节点（不包含自身）
	return root.find_child(target_name, true, false)


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
		print("当前场景节点：")
		_print_node_tree(current_scene, 0)
		return null

# 辅助函数：打印节点树结构
func _print_node_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent + "- " + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		_print_node_tree(child, depth + 1)
