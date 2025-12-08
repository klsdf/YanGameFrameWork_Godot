extends CanvasLayer

## 调试 UI 面板
## 类似 Unity 的 OnGUI，可以在代码中快速创建调试界面
## 使用方式：
##   YanGF.Debug.debug_panel.label("FPS", func(): return str(Engine.get_frames_per_second()))
##   YanGF.Debug.debug_panel.button("保存游戏", func(): YanGF.Save.save_game(0, "test", "data"))

class_name YanDebugPanel

var debug_panel: Panel
var debug_container: VBoxContainer
var debug_items: Dictionary = {}  # 存储调试项，key 为名称，value 为控制节点

func _ready() -> void:
	_create_debug_panel()
	# 默认隐藏，按 ~ 键切换显示
	set_process_input(true)


func _create_debug_panel() -> void:
	# 创建调试面板
	debug_panel = Panel.new()
	debug_panel.name = "DebugPanel"
	debug_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	debug_panel.modulate = Color(1, 1, 1, 0.9)  # 半透明
	
	# 设置样式
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.3, 0.3)
	debug_panel.add_theme_stylebox_override("panel", style_box)
	
	# 创建滚动容器
	var scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll_container.offset_left = 10
	scroll_container.offset_top = 10
	scroll_container.offset_right = -10
	scroll_container.offset_bottom = -10
	# 禁用水平滚动，只允许垂直滚动
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	# 创建内容容器
	debug_container = VBoxContainer.new()
	debug_container.name = "DebugContainer"
	debug_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(debug_container)
	debug_panel.add_child(scroll_container)
	
	add_child(debug_panel)
	debug_panel.visible = false


func _input(event: InputEvent) -> void:
	"""按 ~ 键切换调试面板显示"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_QUOTELEFT:  # ~ 键
			debug_panel.visible = not debug_panel.visible


## 添加标签（动态更新）
## @param item_name: 标签名称
## @param get_value: 获取值的函数，每次更新时调用
## @param update_interval: 更新间隔（秒），默认 0.1 秒
func label(item_name: String, get_value: Callable, update_interval: float = 0.1) -> void:
	# 如果已存在，先移除
	if debug_items.has(item_name):
		debug_items[item_name].queue_free()
		debug_items.erase(item_name)
	
	# 创建标签容器（水平布局，但允许文本换行）
	var label_container = HBoxContainer.new()
	label_container.name = item_name
	label_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 名称标签
	var name_label = Label.new()
	name_label.text = item_name + ": "
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.custom_minimum_size.x = 120  # 设置最小宽度，但允许换行
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	name_label.add_theme_color_override("font_color", Color.CYAN)
	label_container.add_child(name_label)
	
	# 值标签
	var value_label = Label.new()
	value_label.name = "ValueLabel"
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.add_theme_color_override("font_color", Color.WHITE)
	label_container.add_child(value_label)
	
	debug_container.add_child(label_container)
	debug_items[item_name] = label_container
	
	# 设置更新定时器
	var timer = Timer.new()
	timer.wait_time = update_interval
	timer.autostart = true
	timer.timeout.connect(func():
		if is_instance_valid(value_label) and get_value.is_valid():
			value_label.text = str(get_value.call())
	)
	label_container.add_child(timer)


## 添加按钮
## @param item_name: 按钮文本
## @param callback: 点击回调函数
func button(item_name: String, callback: Callable) -> void:
	# 如果已存在，先移除
	if debug_items.has(item_name):
		debug_items[item_name].queue_free()
		debug_items.erase(item_name)
	
	var btn = Button.new()
	btn.text = item_name
	btn.custom_minimum_size.y = 30
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(callback)
	
	debug_container.add_child(btn)
	debug_items[item_name] = btn


## 添加分隔线
func separator() -> void:
	var sep = HSeparator.new()
	debug_container.add_child(sep)


## 添加标题（用于标记区块）
## @param title_text: 标题文本
func title(title_text: String) -> void:
	# 创建标题容器
	var title_container = MarginContainer.new()
	title_container.add_theme_constant_override("margin_top", 5)
	title_container.add_theme_constant_override("margin_bottom", 5)
	
	# 创建标题标签
	var title_label = Label.new()
	title_label.text = "━━━ " + title_text + " ━━━"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))  # 浅蓝色
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	title_container.add_child(title_label)
	debug_container.add_child(title_container)


## 移除调试项
## @param item_name: 要移除的项名称
func remove(item_name: String) -> void:
	if debug_items.has(item_name):
		debug_items[item_name].queue_free()
		debug_items.erase(item_name)


## 清空所有调试项
func clear() -> void:
	for item in debug_items.values():
		item.queue_free()
	debug_items.clear()


## 设置调试面板可见性
func set_panel_visible(is_visible: bool) -> void:
	if debug_panel:
		debug_panel.visible = is_visible
