"""
游戏框架类
不需要autoload
"""

## 游戏框架类
class_name YanGF
extends RefCounted


static var _util: YanUtil
static var Util: YanUtil:## 工具类
	get:
		if not _util:
			_util = YanUtil.new()
		return _util

static var _debug: YanDebug
static var Debug: YanDebug:## 调试类
	get:
		if not _debug:
			_debug = YanDebug.new()
		return _debug


static var _log: YanLogController
static var Log: YanLogController:## 日志类
	get:
		if not _log:
			_log = YanLogController.new()
		return _log


static var _csv: YanCSVManager
static var CSV: YanCSVManager:## CSV管理器
	get:
		if not _csv:
			_csv = YanCSVManager.new()
		return _csv
