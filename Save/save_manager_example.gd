
func _save_test_data() -> void:
	"""保存测试数据"""
	# 保存测试数据（包括对象）
	YanGF.Save.save_game("test_data", "这是测试数据")
	YanGF.Save.save_game("test_number", 12345)
	YanGF.Save.save_game("test_time", Time.get_datetime_string_from_system())
	
	# 测试保存对象
	var test_entry = HotSearchEntry.new()
	test_entry.id = 999
	test_entry.title = "测试热搜"
	test_entry.content = "这是一个测试热搜内容"
	test_entry.show_on_time = 1
	YanGF.Save.save_game("test_hot_search", test_entry)
	
	# 测试保存对象数组
	var keyword1 = Keyword.new()
	keyword1.keyword = "测试关键词1"
	var keyword2 = Keyword.new()
	keyword2.keyword = "测试关键词2"
	YanGF.Save.save_game("test_keywords", [keyword1, keyword2])
	
	print("[YanSaveManager] 测试：已保存数据")
