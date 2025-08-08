class_name CustomSyntaxHighlighter
extends CodeHighlighter


# 初始化方法
func _init():
	print("CustomSyntaxHighlighter _init()")
	
	# 设置基础颜色（对应截图中的颜色设置）
	number_color = Color(0.782, 0.083, 0.533)        # 数字颜色
	symbol_color = Color.GREEN             # 符号颜色
	function_color = Color.LIGHT_BLUE    # 函数颜色
	member_variable_color = Color.PINK     # 成员变量颜色
	
	# 添加关键字颜色（对应截图中的 Keyword Colors）
	add_keyword_color("print", Color.RED)
	add_keyword_color("print_debug", Color.RED)
	add_keyword_color("print_verbose", Color.RED)
	add_keyword_color("print_warning", Color.RED)
	add_keyword_color("print_error", Color.RED)
	add_keyword_color("print_fatal", Color.RED)
	add_keyword_color("print_script", Color.RED)
	add_keyword_color("func", Color.VIOLET)
	add_keyword_color("var", Color.KHAKI)
	add_keyword_color("const", Color.BLUE)
	add_keyword_color("if", Color.NAVAJO_WHITE)
	add_keyword_color("else", Color.BLUE)
	add_keyword_color("for", Color.BLUE)
	add_keyword_color("while", Color.BLUE)
	add_keyword_color("return", Color.PINK)
	add_keyword_color("extends", Color.BLUE)
	add_keyword_color("class_name", Color.BLUE)
	
	# 添加成员关键字颜色（对应截图中的 Member Keyword Colors）
	add_member_keyword_color("text", Color.YELLOW)
	add_member_keyword_color("position", Color.YELLOW)
	add_member_keyword_color("size", Color.YELLOW)
	
	# 添加颜色区域（对应截图中的 Color Regions）
	add_color_region("\"", "\"", Color.ORANGE)  # 字符串
	add_color_region("#", "", Color.GRAY)       # 注释

# CodeHighlighter 会自动处理关键字高亮，所以我们不需要重写这个方法
# 如果需要自定义高亮逻辑，可以重写 _get_line_syntax_highlighting 方法
