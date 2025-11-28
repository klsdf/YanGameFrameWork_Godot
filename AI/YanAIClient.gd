extends Node
class_name YanAIClient

## AI客户端，用于与OpenRouter API通信
## 这是框架提供的AI通信模块

# OpenRouter API配置
const BASE_URL = "https://openrouter.ai/api/v1"
# const DEFAULT_MODEL = "openai/gpt-4o"
# const DEFAULT_MODEL_MINI = "openai/gpt-4o-mini"
# const DEFAULT_MODEL = "qwen/qwen-plus-32b"
const DEFAULT_MODEL = "google/gemini-2.5-pro"
var api_key = ""

var key_file_path: String = "res://api_key.txt"


# HTTP请求节点
var http_request: HTTPRequest

# 信号
signal response_received(content: String)
signal request_failed(error: String)

func _init():
	# 从文件读取API key
	var key = load_api_key()
	if key != "":
		set_api_key(key)
	else:
		push_error("无法读取API key文件: " + key_file_path)


	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

# 从文件读取API key
func load_api_key() -> String:
	var file = FileAccess.open(key_file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text().strip_edges()
		file.close()
		return content
	return ""


# 发送聊天完成请求
func chat_completion(messages: Array) -> void:
	var url = BASE_URL + "/chat/completions"
	
	# 构建请求体
	var body = {
		"model": DEFAULT_MODEL,
		"messages": messages
	}
	
	var json_body = JSON.stringify(body)
	
	# 设置请求头
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	# 发送POST请求
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		request_failed.emit("HTTP请求失败: " + str(error))

# 简单的单消息请求
func ask(question: String) -> void:
	var messages = [
		{
			"role": "user",
			"content": question
		}
	]
	chat_completion(messages)

# 处理响应
func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("请求失败，结果码: " + str(result))
		return
	
	if response_code != 200:
		request_failed.emit("HTTP错误码: " + str(response_code))
		return
	
	# 解析响应
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		request_failed.emit("JSON解析失败")
		return
	
	var response = json.data
	
	# 提取AI回复内容
	if response.has("choices") and response.choices.size() > 0:
		var content = response.choices[0].message.content
		response_received.emit(content)
	else:
		request_failed.emit("响应格式错误")

# 设置API密钥
func set_api_key(key: String) -> void:
	api_key = key

# 设置额外的请求头（可选，用于在openrouter.ai上排名）
func chat_completion_with_headers(messages: Array, site_url: String = "", site_name: String = "") -> void:
	var url = BASE_URL + "/chat/completions"
	
	var body = {
		"model": DEFAULT_MODEL,
		"messages": messages
	}
	
	var json_body = JSON.stringify(body)
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	# 添加可选的额外请求头
	if site_url != "":
		headers.append("HTTP-Referer: " + site_url)
	if site_name != "":
		headers.append("X-Title: " + site_name)
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		request_failed.emit("HTTP请求失败: " + str(error))

