class_name ScriptRunner

extends Node

func code_run(input: TextEdit, output: CodeEditOutput):
	"""
	执行用户输入的代码
	"""

	YanGF.Debug.print(get_class(), "开始执行代码")	
	# 获取用户输入的代码字符串
	var user_code = input.text
	# 检查用户输入是否为空
	if user_code.is_empty():
		output.set_output_text("请输入代码！")
		return
	
	# 创建动态脚本
	var script = GDScript.new()

	

	var full_code = """
extends Node
var dialog_system = null

%s
""" % user_code
	
	# 设置脚本源代码
	script.set_source_code(full_code)
	var log_content = ""
	# 重新加载脚本（检查是否有编译错误）
	var reload_err: Error = script.reload()
	if reload_err != OK:
		var err_text := error_string(reload_err)
		var parts := []
		parts.append("编译失败：%s (错误码=%s)" % [err_text, str(reload_err)])
		print("\n".join(parts))

		log_content = YanGF.Log.read_log_files()	
		output.set_output_text(log_content)
		return
	else:
		print("代码编译成功")

	# 创建实例并执行
	var instance = script.new()
	add_child(instance)  # 添加到当前节点下
	# if dialog_system != null:
	# 	instance.set("dialog_system", dialog_system)

	# 执行用户代码
	if instance.has_method("test"):
		var result = instance.test()
		print(str(result))
		DialogSystem.Instance.speak(str(result))
	else:
		DialogSystem.Instance.speak("代码执行失败！看看是不是把函数名写错了哦~一定要写test") 
		print("用户代码执行失败！")

	if "a" in instance:
		var result2 = instance.a
		DialogSystem.Instance.speak("代码执行成功啦！\n好厉害！") 
		print("用户代码执行结果: ", result2)
	else:
		DialogSystem.Instance.speak("代码执行失败！没有定义a是无法执行的哦~~")
		print("用户代码执行失败！")
	# 执行完后记得移除
	instance.queue_free()

	YanGF.Debug.print(get_class(), "代码执行完成")
	log_content = YanGF.Log.read_log_files()
	output.set_output_text(log_content)


# 使用示例：
# 在代码编辑器中输入以下代码来修改对话框内容：
#
# func test():
#     dialog_label.text = "Hello from dynamic code!"
#     return "对话框已更新"
#
# 或者检查节点是否存在：
# func test():
#     if dialog_label:
#         dialog_label.text = "test"
#         return "对话框内容已修改为: test"
#     else:
#         return "未找到对话框节点"
