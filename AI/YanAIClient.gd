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
var http_client: HTTPClient  # 用于流式传输

# 信号
signal response_received(content: String)
signal request_failed(error: String)
signal stream_chunk_received(content: String)  # 流式传输时接收到的内容片段
signal stream_completed()  # 流式传输完成
signal stream_failed(error: String)  # 流式传输失败

# 流式传输相关变量
var is_streaming: bool = false
var stream_buffer: String = ""

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
	
	# 初始化HTTP客户端用于流式传输
	http_client = HTTPClient.new()

# 从文件读取API key
func load_api_key() -> String:
	var file = FileAccess.open(key_file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text().strip_edges()
		file.close()
		return content
	return ""


# 流式传输聊天完成请求
func chat_completion_stream(messages: Array) -> void:
	if is_streaming:
		stream_failed.emit("已有流式请求正在进行中")
		return
	
	var url = BASE_URL + "/chat/completions"
	
	# 构建请求体，添加 stream: true
	var body = {
		"model": DEFAULT_MODEL,
		"messages": messages,
		"stream": true
	}
	
	var json_body = JSON.stringify(body)
	
	# 解析URL
	var url_parts = url.split("/")
	var host = url_parts[2]
	var path = "/" + "/".join(url_parts.slice(3, url_parts.size()))
	var use_ssl = url.begins_with("https://")
	
	# 连接到服务器
	var tls_options = null
	if use_ssl:
		tls_options = TLSOptions.client()
	var error = http_client.connect_to_host(host, 443 if use_ssl else 80, tls_options)
	if error != OK:
		stream_failed.emit("连接失败: " + str(error))
		return
	
	is_streaming = true
	stream_buffer = ""
	
	# 等待连接建立
	var max_wait_time = 5000  # 最多等待5秒
	var start_time = Time.get_ticks_msec()
	while http_client.get_status() == HTTPClient.STATUS_CONNECTING or http_client.get_status() == HTTPClient.STATUS_RESOLVING:
		http_client.poll()
		if Time.get_ticks_msec() - start_time > max_wait_time:
			is_streaming = false
			stream_failed.emit("连接超时")
			http_client.close()
			return
		await get_tree().process_frame
	
	# 检查连接状态
	var status = http_client.get_status()
	if status != HTTPClient.STATUS_CONNECTED:
		is_streaming = false
		stream_failed.emit("连接失败，状态码: " + str(status))
		http_client.close()
		return
	
	# 发送请求
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	error = http_client.request(HTTPClient.METHOD_POST, path, headers, json_body)
	if error != OK:
		is_streaming = false
		stream_failed.emit("请求发送失败: " + str(error))
		http_client.close()
		return
	
	# 开始处理流式响应
	_process_stream_response()

# 处理流式响应
func _process_stream_response() -> void:
	while is_streaming:
		http_client.poll()
		
		var status = http_client.get_status()
		
		if status == HTTPClient.STATUS_CONNECTING or status == HTTPClient.STATUS_RESOLVING:
			await get_tree().process_frame
			continue
		
		if status == HTTPClient.STATUS_CONNECTION_ERROR or status == HTTPClient.STATUS_CANT_CONNECT:
			is_streaming = false
			stream_failed.emit("连接错误")
			http_client.close()
			return
		
		if status == HTTPClient.STATUS_BODY or status == HTTPClient.STATUS_CONNECTED:
			# 读取数据块
			# 在 Godot 4 中，直接尝试读取数据块，如果返回空数组则表示没有数据
			var chunk = http_client.read_response_body_chunk()
			if chunk.size() > 0:
				_process_chunk(chunk)
		
		if status == HTTPClient.STATUS_DISCONNECTED:
			# 处理剩余的缓冲区数据
			if stream_buffer.length() > 0:
				_process_buffer_lines()
			is_streaming = false
			stream_completed.emit()
			http_client.close()
			return
		
		await get_tree().process_frame

# 处理接收到的数据块
func _process_chunk(chunk: PackedByteArray) -> void:
	var text = chunk.get_string_from_utf8()
	if text == "":
		return
	
	stream_buffer += text
	
	# 处理缓冲区中的完整行
	_process_buffer_lines()

# 处理缓冲区中的完整行
func _process_buffer_lines() -> void:
	while true:
		var line_end = stream_buffer.find("\n")
		if line_end == -1:
			break
		
		var line = stream_buffer.substr(0, line_end).strip_edges()
		stream_buffer = stream_buffer.substr(line_end + 1)
		
		if line.begins_with("data: "):
			var data = line.substr(6)  # 移除 "data: " 前缀
			
			if data == "[DONE]":
				is_streaming = false
				stream_completed.emit()
				http_client.close()
				return
			
			if data == "":
				continue
			
			# 解析JSON
			var json = JSON.new()
			var parse_result = json.parse(data)
			
			if parse_result == OK:
				var parsed = json.data
				if parsed.has("choices") and parsed.choices.size() > 0:
					var choice = parsed.choices[0]
					if choice.has("delta") and choice.delta.has("content"):
						var content = choice.delta.content
						if content != null and content != "":
							stream_chunk_received.emit(content)



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
