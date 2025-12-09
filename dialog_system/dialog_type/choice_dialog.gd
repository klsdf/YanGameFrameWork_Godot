extends DialogScriptBase
class_name ChoiceDialog

# 单个对话脚本


var choices:Array[DialogChoiceItem]

func _init(choices_items: Array[DialogChoiceItem]):
	self.choices = choices_items
	
