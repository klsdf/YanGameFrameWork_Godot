# Godot 错误处理系统

这个错误处理系统允许你在Godot游戏中捕捉和处理各种错误，包括脚本错误、运行时错误等，并在游戏内显示详细的错误信息。

## 功能特性

- **自动错误捕捉**：自动捕捉脚本编译错误和运行时错误
- **详细错误信息**：显示错误类型、位置、详细信息等
- **错误日志管理**：记录所有错误，支持查看和清空
- **游戏内显示**：在游戏内显示美观的错误信息面板
- **错误分类**：将错误按类型分类（脚本解析、运行时、系统等）
- **语法检查**：提供基本的语法错误检测

## 文件结构

```
YanGameFrameWork_Godot/CodeEdit/
├── ErrorHandler.gd          # 核心错误处理器
├── ErrorDisplay.tscn        # 错误显示UI场景
├── ErrorDisplay.gd          # 错误显示UI脚本
├── ErrorHandlingExample.tscn # 使用示例场景
├── ErrorHandlingExample.gd  # 使用示例脚本
└── yan_code_edit.gd         # 集成了错误处理的代码编辑器
```

## 使用方法

### 1. 基本集成

在你的脚本中预加载并使用错误处理器：

```gdscript
# 预加载错误处理器
const ErrorHandler = preload("res://YanGameFrameWork_Godot/Util/ErrorHandler.gd")

# 创建错误处理器实例
var error_handler: ErrorHandler

func _ready():
    # 初始化错误处理器
    error_handler = ErrorHandler.new()
    
    # 连接错误信号
    error_handler.script_error_occurred.connect(_on_script_error)
    error_handler.error_occurred.connect(_on_error)

func _on_script_error(error_info: Dictionary):
    print("脚本错误：", error_info)
    # 处理脚本错误

func _on_error(error_info: Dictionary):
    print("一般错误：", error_info)
    # 处理一般错误
```

### 2. 脚本错误捕捉

使用错误处理器来捕捉脚本编译错误：

```gdscript
func compile_script(script: GDScript, user_code: String):
    # 使用错误处理器捕捉脚本错误
    var error_info = error_handler.capture_script_error(script, user_code)
    
    if error_info.has("error_code"):
        # 脚本编译失败
        print("编译失败：", error_handler.format_error_message(error_info))
    else:
        # 脚本编译成功
        print("编译成功")
```

### 3. 错误显示UI

使用错误显示UI来显示错误信息：

```gdscript
# 预加载错误显示UI
const ErrorDisplayScene = preload("res://YanGameFrameWork_Godot/CodeEdit/ErrorDisplay.tscn")

# 创建错误显示UI实例
var error_display: ErrorDisplay

func _ready():
    error_display = ErrorDisplayScene.instantiate()
    error_display.set_error_handler(error_handler)
    add_child(error_display)

func show_error(error_info: Dictionary):
    # 显示错误信息
    error_display.show_error(error_info)

func show_error_log():
    # 显示错误日志
    error_display.show_error_log()
```

## 错误类型

系统支持以下错误类型：

- **SCRIPT_PARSE**：脚本解析错误（语法错误）
- **SCRIPT_RUNTIME**：脚本运行时错误
- **SYSTEM**：系统错误
- **WARNING**：警告
- **CRASH**：崩溃

## 错误信息结构

每个错误信息包含以下字段：

```gdscript
{
    "type": "错误类型字符串",
    "message": "错误消息",
    "file": "错误文件路径",
    "line": 错误行号,
    "function": "错误函数名",
    "stack": 错误堆栈,
    "timestamp": "时间戳",
    "error_type": 错误类型枚举值,
    "user_code": "用户代码（如果是脚本错误）",
    "error_code": 错误码,
    "details": 详细错误信息
}
```

## 快捷键

在示例场景中支持以下快捷键：

- **Ctrl+R**：运行代码
- **Ctrl+L**：显示错误日志
- **Ctrl+K**：清空错误日志

## 高级功能

### 1. 自定义错误处理

你可以继承 `ErrorHandler` 类来自定义错误处理逻辑：

```gdscript
class_name CustomErrorHandler
extends ErrorHandler

func _on_engine_error(error_type: String, error_message: String, error_file: String, error_line: int, error_function: String, error_stack: PackedStringArray):
    # 自定义错误处理逻辑
    super._on_engine_error(error_type, error_message, error_file, error_line, error_function, error_stack)
    
    # 添加你的自定义逻辑
    if error_type == "Script Error":
        # 特殊处理脚本错误
        pass
```

### 2. 错误日志持久化

你可以将错误日志保存到文件中：

```gdscript
func save_error_log():
    var file = FileAccess.open("user://error_log.json", FileAccess.WRITE)
    if file:
        var json = JSON.new()
        var json_string = json.stringify(error_handler.get_error_log())
        file.store_string(json_string)
        file.close()
```

### 3. 错误报告

你可以添加错误报告功能：

```gdscript
func report_error(error_info: Dictionary):
    # 发送错误报告到服务器
    var http_request = HTTPRequest.new()
    add_child(http_request)
    
    var data = {
        "error": error_info,
        "game_version": "1.0.0",
        "platform": OS.get_name()
    }
    
    var json = JSON.new()
    var json_string = json.stringify(data)
    
    http_request.request("https://your-server.com/report-error", [], HTTPClient.METHOD_POST, json_string)
```

## 注意事项

1. **性能影响**：错误处理器会略微影响性能，建议在开发环境中使用
2. **内存管理**：错误日志会占用内存，定期清理或限制日志大小
3. **错误循环**：避免在错误处理函数中产生新的错误
4. **线程安全**：错误处理器不是线程安全的，只在主线程中使用

## 故障排除

### 常见问题

1. **错误处理器未初始化**
   - 确保在 `_ready()` 函数中初始化错误处理器

2. **错误显示UI不显示**
   - 检查错误显示UI是否正确添加到场景树中
   - 确保错误处理器已设置

3. **错误信号未连接**
   - 检查信号连接是否正确
   - 确保在初始化后再连接信号

### 调试技巧

1. 使用 `print()` 输出错误信息进行调试
2. 检查错误日志中的详细信息
3. 使用Godot的调试器查看错误堆栈

## 更新日志

- **v1.0.0**：初始版本，支持基本的错误捕捉和显示
- 支持脚本错误、运行时错误、系统错误等
- 提供美观的错误显示UI
- 支持错误日志管理
