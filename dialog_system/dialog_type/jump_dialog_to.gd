extends DialogScriptBase
class_name JumpDialogTo


var next_dialog_name: DialogBlock
## 跳转对话块
## @param p_next_dialog_name: 跳转的对话块
func _init(p_next_dialog_name: DialogBlock):
	self.next_dialog_name = p_next_dialog_name