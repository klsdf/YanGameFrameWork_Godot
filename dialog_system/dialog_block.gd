
extends RefCounted
class_name DialogBlock


var name: String
var dialog_scripts: Array[DialogScriptBase]

func _init(p_name: String = "", p_dialog_scripts: Array[DialogScriptBase] = []):
	name = p_name
	dialog_scripts = p_dialog_scripts

# 支持for循环迭代
var _iter_index: int = 0

func _iter_init(_previous: Variant) -> bool:
	_iter_index = 0
	return _iter_index < dialog_scripts.size()

func _iter_get(_previous: Variant) -> Variant:
	var result = dialog_scripts[_iter_index]
	_iter_index += 1
	return result

func _iter_next(_previous: Variant) -> bool:
	return _iter_index < dialog_scripts.size()



