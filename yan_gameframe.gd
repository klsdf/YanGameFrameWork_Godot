class_name YanGameFrameWork
extends Node

"""
游戏框架全局挂载点
自动加载后，其他脚本可以通过 YanGameFrameWork 访问所有工具类
"""

# 预加载所有工具类
var yan_util: YanUtil

func _ready():
	# 创建工具类实例
	yan_util = YanUtil.new()
	print("YanGameFrameWork 已启动！")
	print("可以通过 YanGameFrameWork.yan_util 访问工具类")
