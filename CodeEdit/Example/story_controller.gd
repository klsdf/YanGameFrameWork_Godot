class_name StoryController
extends RefCounted

class Story:
	
	var content: String
	var error_content: String
	var right_content: String
	var expect_answer: Variant

	var check_variable_name: String
	var check_method_name: String
	
	## 构造函数
	## @param p_name 故事名称
	## @param p_content 故事内容
	## @param p_error_content 错误内容
	## @param p_right_content 正确内容
	## @param p_expect_answer 期望答案
	func _init( 
		p_content: String = "", 
		p_error_content: String = "", 
		p_right_content: String = "", 
		p_expect_answer: Variant = null,
		p_check_variable_name: String = "",
		p_check_method_name: String = ""):
		content = p_content
		error_content = p_error_content
		right_content = p_right_content
		expect_answer = p_expect_answer
	
	func set_check_variable_name(p_check_variable_name: String):
		check_variable_name = p_check_variable_name
		return self
	
	func set_check_method_name(p_check_method_name: String):
		check_method_name = p_check_method_name
		return self


var story: Array[Story] = [
		Story.new("第一题，定义变量a，并且赋值为1", "错误内容", "正确内容", 1),
		Story.new( "这是一个故事2", "错误内容2", "正确内容2", null)
	]
