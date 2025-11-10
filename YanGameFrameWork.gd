class_name YanGF
extends RefCounted

"""
游戏框架单例类
通过 YanGameFrameWork.Instance() 访问实例
"""


# # 单例实例
# static var _instance: YanGF

# # 静态访问器
# static var Instance: YanGF:
# 	get:
# 		if not _instance:
# 			_instance = YanGF.new()
# 			_instance.initialize()
# 		return _instance



# 预加载所有工具类
static var _util: YanUtil
static var Util: YanUtil:
	get:
		if not _util:
			_util = YanUtil.new()
		return _util

static var _debug: YanDebug
static var Debug: YanDebug:
	get:
		if not _debug:
			_debug = YanDebug.new()
		return _debug

static var _log: YanLogController
static var Log: YanLogController:
	get:
		if not _log:
			_log = YanLogController.new()
		return _log

# CSV管理器
static var _csv: YanCSVManager
static var CSV: YanCSVManager:
	get:
		if not _csv:
			_csv = YanCSVManager.new()
		return _csv