extends DialogScriptBase
class_name DialogChoiceItem


var text: String
var alignment: int
var next_dialog_name: DialogBlock
var callback: Callable


## 初始化玩家的选择项
## @param p_text: 选择项文本
## @param p_next_dialog_name: 选择项对应的对话块
## @param p_callback: 选择项对应的回调函数
func _init(p_text: String,p_next_dialog_name: DialogBlock,p_callback: Callable = func(): pass):
	self.text = p_text
	self.alignment = HORIZONTAL_ALIGNMENT_CENTER
	self.next_dialog_name = p_next_dialog_name
	self.callback = p_callback