class_name YanDebug
extends RefCounted

var _debug_panel: YanDebugPanel
var debug_panel: YanDebugPanel:
	get:
		if not _debug_panel:
			# 创建调试面板实例并添加到场景树
			_debug_panel = YanDebugPanel.new()
			# 获取场景树根节点并添加
			if Engine.get_main_loop():
				var scene_tree = Engine.get_main_loop() as SceneTree
				if scene_tree and scene_tree.root:
					scene_tree.root.add_child(_debug_panel)
		return _debug_panel


func print(caller: String, text: String):
	print("yan_debug: ", caller, ": ", text)
