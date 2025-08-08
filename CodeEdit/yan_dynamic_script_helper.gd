class_name YanDynamicScriptHelper
extends RefCounted

# 预定义的节点引用和工具函数
var dialog_label: Label = null
var scene_tree: SceneTree = null
var current_scene: Node = null

# 初始化函数
func _init(dialog_ref: Label = null, tree: SceneTree = null, scene: Node = null):
	dialog_label = dialog_ref
	scene_tree = tree
	current_scene = scene

# 创建新物体的工具函数
func create_node(node_type: String, node_name: String = "") -> Node:
	if scene_tree and current_scene:
		var new_node = null
		match node_type:
			"Label":
				new_node = Label.new()
			"Button":
				new_node = Button.new()
			"Sprite2D":
				new_node = Sprite2D.new()
			"Node2D":
				new_node = Node2D.new()
			"Control":
				new_node = Control.new()
			"Panel":
				new_node = Panel.new()
			"VBoxContainer":
				new_node = VBoxContainer.new()
			"HBoxContainer":
				new_node = HBoxContainer.new()
			"TextureRect":
				new_node = TextureRect.new()
			_:
				print("未知的节点类型: ", node_type)
				return null
		
		if new_node:
			if node_name != "":
				new_node.name = node_name
			current_scene.add_child(new_node)
			return new_node
	return null

func create_label(text: String = "", node_name: String = "") -> Label:
	var label = create_node("Label", node_name)
	if label:
		label.text = text
	return label

func create_button(text: String = "", node_name: String = "") -> Button:
	var button = create_node("Button", node_name)
	if button:
		button.text = text
	return button

func create_sprite2d(texture_path: String = "", node_name: String = "") -> Sprite2D:
	var sprite = create_node("Sprite2D", node_name)
	if sprite and texture_path != "":
		var texture = load(texture_path)
		if texture:
			sprite.texture = texture
	return sprite

# 查找节点的工具函数
func find_node(node_name: String) -> Node:
	if scene_tree:
		return scene_tree.get_root().get_node_or_null(node_name)
	return null

# 递归查找节点
func find_node_recursive(node_name: String) -> Node:
	if scene_tree:
		return _find_node_recursive_helper(scene_tree.get_root(), node_name)
	return null

func _find_node_recursive_helper(current_node: Node, target_name: String) -> Node:
	# 检查当前节点
	if current_node.name == target_name:
		return current_node

	# 递归检查所有子节点
	for child in current_node.get_children():
		var result = _find_node_recursive_helper(child, target_name)
		if result:
			return result

	return null

# 获取场景树中所有节点的工具函数
func get_all_nodes() -> Array:
	var result = []
	if scene_tree:
		_collect_nodes_recursive(scene_tree.get_root(), result)
	return result

func _collect_nodes_recursive(node: Node, result: Array) -> void:
	result.append(node)
	for child in node.get_children():
		_collect_nodes_recursive(child, result)

# 打印场景树结构的工具函数
func print_scene_tree() -> String:
	var result = ""
	if scene_tree:
		result = _print_node_recursive(scene_tree.get_root(), 0)
	return result

func _print_node_recursive(node: Node, depth: int) -> String:
	var indent = "  ".repeat(depth)
	var result = indent + "- " + node.name + " (" + node.get_class() + ")\n"
	for child in node.get_children():
		result += _print_node_recursive(child, depth + 1)
	return result
