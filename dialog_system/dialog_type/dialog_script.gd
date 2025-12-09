extends DialogScriptBase
class_name DialogScript

# 单个对话脚本
var text: String
var alignment: int
var callback: Callable


## 初始化对话脚本
## @param p_text: 对话文本
## @param p_alignment: 对话对齐方式
## @param p_callback: 对话执行时的回调函数
func _init(p_text: String = "", p_alignment: int = HORIZONTAL_ALIGNMENT_LEFT, p_callback: Callable = func(): pass):
	text = p_text
	alignment = p_alignment
	callback = p_callback
