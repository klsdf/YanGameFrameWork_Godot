class_name YanGameFrameWork
extends Node

"""
游戏框架全局挂载点
自动加载后，其他脚本可以通过 YanGameFrameWork 访问所有工具类
"""

# 预加载所有工具类
var yan_util: YanUtil
var yan_debug: YanDebug
var log_controller: LogController

func _ready():
	# 创建工具类实例
	yan_util = YanUtil.new()
	yan_debug = YanDebug.new()
	log_controller = LogController.new()
	yan_debug.print("YanGameFrameWork", "已启动！")

