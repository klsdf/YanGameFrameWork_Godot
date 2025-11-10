"""
Author: 闫辰祥
Date: 2025-11-10 11:00
Description: 代码风格规范的模板，所有代码前都需要加这个。
文件的规范要参考本目录下的 编辑器内文件命名规范.md
整体风格参考：https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_styleguide.html

修改记录：
	2025-11-10 闫辰祥 创建，一般默认可以不写，第一次写完之后，如果对代码有更改。需要加这个注释。
"""

extends Node

## 类前需要用文档注释，来解释这玩意是干啥用的
## 类名使用PascalCase风格，要注意类的文件使用snake_case风格
class_name YanProgrammingStyle

## 自定义信号需要注释，信号名使用snake_case风格
signal button_start_game_pressed()

## 所有常量均使用UPPER_SNAKE_CASE
const I_AM_CONST = 100

## 显示类型枚举
## 枚举类型使用PascalCase风格，枚举值使用UPPER_SNAKE_CASE
## 枚举值的注释要写在枚举值的后面，防止迷惑行为
enum GameState {
	STATE_IDLE,# 空闲状态
	STATE_PLAYING,# 游戏进行中
	STATE_PAUSED,# 暂停状态
	STATE_GAME_OVER,# 游戏结束状态
}

## 所有公有变量都使用snake_case
## 所有私有变量使用_前缀，之后再使用snake_case
## 所有的变量和属性都需要把含义或者数据类型写在开头，例如 _button_start_game，label_title,list_player_position
## 变量的含义尽量不要写缩写，button 不要写成 btn。background 不要写成 bg。
@export var panel_title: String = "Example Panel" 

@onready var label_title: Label = $TitleLabel 

var current_game_state: GameState = GameState.STATE_IDLE

var player_name: String = ""## 对于简单的类型，可以内联文档注释，或者不写

var _display_count: int = 0 ## 私有变量使用_前缀+snake_case

## 对于私有的静态变量也是一样使用snake_case
static var _instance: YanProgrammingStyle

## 对于公有的静态变量，使用PascalCase风格
static var Instance: YanProgrammingStyle



## 私有函数使用_前缀+snake_case
func _private_func():
	pass


## 公有函数使用snake_case
func public_func():
	pass

## 函数需要用文档注释说明白参数，返回值和含义
## 计算两个整数的和
## @param a: 第一个整数
## @param b: 第二个整数
## @return: 返回两个整数的和
func calculate_sum(a: int, b: int) -> int:
	return a + b

