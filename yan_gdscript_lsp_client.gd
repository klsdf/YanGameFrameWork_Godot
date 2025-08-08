class_name YanGDScriptLSPClient


extends RefCounted


func analyze_code(code:String, host:String, port:int) -> Array:
	var result:Array = []
	var tcp := StreamPeerTCP.new()
	var err := tcp.connect_to_host(host, port)
	if err != OK:
		print("[LSP] 连接失败，错误码: %s" % err)
		return result

	# 快速检查连接状态，如果被占用就立即返回
	var quick_check := Time.get_ticks_msec() + 100
	while tcp.get_status() == StreamPeerTCP.STATUS_CONNECTING and Time.get_ticks_msec() < quick_check:
		OS.delay_msec(5)
	
	if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		print("[LSP] 语言服务器连接被占用或不可用（编辑器可能正在使用）")
		tcp.disconnect_from_host()
		return result

	print("[LSP] 连接成功")

	# initialize
	var init_req := {
		"jsonrpc": "2.0",
		"id": 1,
		"method": "initialize",
		"params": {
			"processId": OS.get_process_id(),
			"clientInfo": {"name": "YanCodeEdit", "version": "1.0"},
			"rootUri": null,
			"capabilities": {}
		}
	}
	print("[LSP] 发送 initialize 请求")
	_lsp_send(tcp, init_req)
	
	# 读取一次回应（可忽略内容）
	var init_resp = _lsp_recv(tcp, 300)
	if init_resp != null:
		print("[LSP] 收到 initialize 响应: %s" % str(init_resp))
	else:
		print("[LSP] 未收到 initialize 响应")

	# initialized 通知
	print("[LSP] 发送 initialized 通知")
	_lsp_send(tcp, {"jsonrpc":"2.0","method":"initialized","params":{}})

	# didOpen 虚拟文档
	var uri := "file:///user_code.gd"
	var did_open := {
		"jsonrpc": "2.0",
		"method": "textDocument/didOpen",
		"params": {
			"textDocument": {
				"uri": uri,
				"languageId": "gdscript",
				"version": 1,
				"text": code
			}
		}
	}
	print("[LSP] 发送 didOpen 请求，代码长度: %d" % code.length())
	_lsp_send(tcp, did_open)

	# 等待 publishDiagnostics
	var deadline = Time.get_ticks_msec() + 800
	var diag_count := 0
	while Time.get_ticks_msec() < deadline:
		var msg = _lsp_recv(tcp, 200)
		if msg != null:
			print("[LSP] 收到消息: %s" % str(msg))
			if typeof(msg) == TYPE_DICTIONARY and msg.has("method") and msg["method"] == "textDocument/publishDiagnostics":
				var params = msg.get("params", {})
				if params.get("uri", "") != uri:
					print("[LSP] URI 不匹配，跳过")
					continue
				var diags = params.get("diagnostics", [])
				print("[LSP] 收到 %d 个诊断" % diags.size())
				for d in diags:
					var rng = d.get("range", {})
					var start = rng.get("start", {})
					result.append({
						"line": int(start.get("line", 0)) + 1,
						"col": int(start.get("character", 0)) + 1,
						"message": str(d.get("message", ""))
					})
					diag_count += 1
				break
		OS.delay_msec(10)

	print("[LSP] 总共收到 %d 个诊断" % diag_count)

	# 断开
	tcp.disconnect_from_host()
	return result


func _lsp_send(tcp:StreamPeerTCP, obj:Variant) -> void:
	var body := JSON.stringify(obj)
	var header := "Content-Length: %d\r\n\r\n" % body.length()
	var full_msg := header + body
	print("[LSP] 发送: %s" % full_msg)
	tcp.put_data(full_msg.to_utf8_buffer())


func _lsp_recv(tcp:StreamPeerTCP, timeout_ms:int) -> Variant:
	var end_time := Time.get_ticks_msec() + timeout_ms
	var buffer := ""
	while Time.get_ticks_msec() < end_time:
		var n := tcp.get_available_bytes()
		if n > 0:
			var chunk := tcp.get_utf8_string(n)
			buffer += chunk
			print("[LSP] 收到数据块: %s" % chunk)
			
			var sep := buffer.find("\r\n\r\n")
			if sep != -1:
				var header_text := buffer.substr(0, sep)
				var content_length := -1
				for line in header_text.split("\r\n"):
					if line.begins_with("Content-Length:"):
						content_length = int(line.split(":")[1].strip_edges())
						break
				if content_length >= 0:
					var body_start := sep + 4
					if buffer.length() - body_start < content_length:
						print("[LSP] 数据不完整，继续等待")
						continue
					var body_text := buffer.substr(body_start, content_length)
					print("[LSP] 解析 JSON: %s" % body_text)
					var json := JSON.new()
					var jerr := json.parse(body_text)
					if jerr == OK:
						print("[LSP] JSON 解析成功")
						return json.data
					else:
						print("[LSP] JSON 解析失败: %s" % jerr)
						return null
		OS.delay_msec(10)
	print("[LSP] 接收超时")
	return null


