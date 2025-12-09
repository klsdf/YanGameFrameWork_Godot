extends Node
class_name DialogController

## 对话系统控制器
## 负责处理对话流程逻辑，不涉及UI操作
## 通过信号与外部通信，支持异步处理

## 信号定义
## 需要显示一条消息
signal message_should_display(text: String, alignment: int)
## 需要显示选项
signal options_should_show(choices: Array[DialogChoiceItem])
## 对话结束
signal dialog_ended()
## 需要执行回调
signal callback_requested(callback: Callable)

## 对话状态
var current_block: DialogBlock = null
var pending_choice_dialog: ChoiceDialog = null
var is_processing: bool = false

## 延迟时间配置
const DEFAULT_MESSAGE_DELAY: float = 0.5  # 默认消息延迟时间（秒）
const CHOICE_SELECTED_DELAY: float = 0.5   # 选项选择后延迟时间（秒）

## 开始处理对话块（异步）
## @param dialog_block: 要处理的对话块
## @param delay: 消息之间的延迟时间（秒）
## @param should_continue_check: 可选的回调函数，用于检查是否应该继续处理（返回 bool）
func process_dialog_block(dialog_block: DialogBlock, delay: float = DEFAULT_MESSAGE_DELAY, should_continue_check: Callable = Callable()) -> void:
	"""处理对话块，自动处理 DialogScript、ChoiceDialog 和 JumpDialogTo"""
	if is_processing:
		push_warning("[DialogController] 正在处理对话中，忽略新的对话块")
		return
	
	is_processing = true
	current_block = dialog_block
	
	await _process_dialog_block_internal(dialog_block, delay, should_continue_check)
	
	# 只有在没有待处理的选项时才设置为 false
	# 如果有待处理的选项，说明正在等待用户选择，保持 is_processing = true
	if not has_pending_choice():
		is_processing = false

## 内部处理对话块（递归调用，异步）
func _process_dialog_block_internal(dialog_block: DialogBlock, delay: float, should_continue_check: Callable) -> void:
	"""内部处理对话块的方法"""
	for dialog_script in dialog_block:
		# 检查是否应该继续（如果提供了检查函数）
		if should_continue_check.is_valid() and not should_continue_check.call():
			# 如果不再继续，只有在没有待处理的选项时才设置为 false
			if not has_pending_choice():
				is_processing = false
			return
		
		# 使用 is 关键字判断类型
		if dialog_script is DialogScript:
			var simple_dialog_script = dialog_script as DialogScript
			
			# 发出信号，通知需要显示消息
			message_should_display.emit(simple_dialog_script.text, simple_dialog_script.alignment)
			
			# 执行回调函数（如果有）
			if simple_dialog_script.callback.is_valid():
				callback_requested.emit(simple_dialog_script.callback)
			
			# 等待延迟（异步）
			await get_tree().create_timer(delay).timeout
			
		elif dialog_script is ChoiceDialog:
			var choice_dialog = dialog_script as ChoiceDialog
			pending_choice_dialog = choice_dialog
			
			# 发出信号，通知需要显示选项
			options_should_show.emit(choice_dialog.choices)
			
			# 选项显示后，等待用户选择，不需要继续处理后续内容
			# 注意：此时 is_processing 保持为 true，等待用户选择
			return
			
		elif dialog_script is JumpDialogTo:
			var jump = dialog_script as JumpDialogTo
			# 跳转到下一个对话块
			if jump.next_dialog_name:
				current_block = jump.next_dialog_name
				await _process_dialog_block_internal(jump.next_dialog_name, delay, should_continue_check)
			return
			
		elif dialog_script is DialogEnd:
			# 对话结束
			pending_choice_dialog = null
			current_block = null
			is_processing = false
			dialog_ended.emit()
			return
			
		else:
			push_warning("[DialogController] 未知类型的对话脚本: %s" % dialog_script.get_class())

## 处理选项选择（异步）
## @param choice_item: 被选择的选项项
## @param should_continue_check: 可选的回调函数，用于检查是否应该继续处理（返回 bool）
func on_choice_selected(choice_item: DialogChoiceItem, should_continue_check: Callable = Callable()) -> void:
	"""处理选项选择，自动跳转到下一个对话块"""
	if not is_processing:
		push_warning("[DialogController] 未在处理对话中，无法处理选项选择")
		return
	
	# 清除待处理的选项
	pending_choice_dialog = null
	
	# 发出信号，显示玩家选择的消息
	message_should_display.emit(choice_item.text, HORIZONTAL_ALIGNMENT_RIGHT)
	
	# 等待延迟（异步）
	await get_tree().create_timer(CHOICE_SELECTED_DELAY).timeout
	
	# 检查是否应该继续
	if should_continue_check.is_valid() and not should_continue_check.call():
		is_processing = false
		return
	
	# 执行回调函数（如果有）
	if choice_item.callback.is_valid():
		callback_requested.emit(choice_item.callback)
	
	# 自动跳转到下一个对话块
	if choice_item.next_dialog_name:
		current_block = choice_item.next_dialog_name
		await _process_dialog_block_internal(choice_item.next_dialog_name, DEFAULT_MESSAGE_DELAY, should_continue_check)
		# 处理完成后，如果没有待处理的选项，设置为 false
		if not has_pending_choice():
			is_processing = false
	else:
		# 如果没有下一个对话块，结束对话
		current_block = null
		is_processing = false
		dialog_ended.emit()

## 停止当前对话处理
func stop() -> void:
	"""停止当前对话处理"""
	is_processing = false
	current_block = null
	pending_choice_dialog = null

## 检查是否有待处理的选项
func has_pending_choice() -> bool:
	"""检查是否有待处理的选项"""
	return pending_choice_dialog != null

## 获取当前对话块
func get_current_block() -> DialogBlock:
	"""获取当前对话块"""
	return current_block
