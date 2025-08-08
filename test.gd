# extends Node
# const LSP := preload("res://YanGameFrameWork_Godot/yan_gdscript_lsp_client.gd")

# @export var lsp_host: String = "127.0.0.1"
# @export var lsp_port: int = 6005

# func _ready() -> void:
#     var client := LSP.new()

#     # 示例1：正确代码（通常无诊断）
#     var code_ok := "var a = 1\nfunc test():\n\treturn a"

#     # 示例2：错误代码（触发诊断：未定义变量 b）
#     var code_bad := "var a = 1\nfunc test():\n\treturn b"

#     print("=== LSP 调试信息 ===")
#     print("主机: %s, 端口: %d" % [lsp_host, lsp_port])
    
#     # 测试连接
#     var tcp := StreamPeerTCP.new()
#     var err := tcp.connect_to_host(lsp_host, lsp_port)
#     print("连接错误码: %s" % err)
    
#     if err == OK:
#         # 等待连接
#         var deadline := Time.get_ticks_msec() + 1000
#         while tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED and Time.get_ticks_msec() < deadline:
#             OS.delay_msec(10)
#         print("连接状态: %s" % tcp.get_status())
#         tcp.disconnect_from_host()
#     else:
#         print("无法连接到语言服务器，请检查：")
#         print("1. 编辑器是否正在运行")
#         print("2. Editor Settings → Network → Language Server → Enable 是否勾选")
#         print("3. 端口 %d 是否正确" % lsp_port)
#         return

#     # 任选其一进行检测
#     print("\n=== 测试正确代码 ===")
#     var diags_ok := client.analyze_code(code_ok, lsp_host, lsp_port)
#     if diags_ok.is_empty():
#         print("[OK] 正确代码：无诊断")
#     else:
#         for d in diags_ok:
#             print("[OK] 第 %d 行, 第 %d 列: %s" % [d["line"], d["col"], d["message"]])

#     print("\n=== 测试错误代码 ===")
#     var diags_bad := client.analyze_code(code_bad, lsp_host, lsp_port)
#     if diags_bad.is_empty():
#         print("[BAD] 错误代码：无诊断")
#         print("可能原因：")
#         print("1. LSP 连接失败")
#         print("2. 语言服务器未正确处理请求")
#         print("3. 协议解析问题")
#     else:
#         for d in diags_bad:
#             print("[BAD] 第 %d 行, 第 %d 列: %s" % [d["line"], d["col"], d["message"]])