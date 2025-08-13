# YanClass 脚本验证功能说明

## 概述

YanClass 现在提供了强大的脚本编译错误检测和语法验证功能，可以帮助你在编程游戏中实时检测玩家代码的错误，并提供详细的错误信息和修复建议。**最重要的是，现在可以定位到具体的错误行号和列号！**

## 主要功能

### 1. 脚本错误检测 (`get_script_errors`)

检测现有脚本对象的编译错误，返回详细的错误信息。

**参数：**
- `script`: Script 对象

**返回值：** Dictionary 包含以下信息：
- `valid`: bool - 脚本是否有效
- `error_code`: int - 错误代码
- `error`: String - 错误描述
- `error_type`: String - 错误类型
- `source_length`: int - 源代码长度
- `has_source`: bool - 是否有源代码

**使用示例：**
```gdscript
var yan_class = YanClass.new()
var script = GDScript.new()
script.source_code = "extends Node\nfunc _ready():\n\tprint('Hello')"

var result = yan_class.get_script_errors(script)
if not result["valid"]:
    print("错误类型: ", result["error_type"])
    print("错误描述: ", result["error"])
```

### 2. 语法验证 (`validate_script_syntax`)

验证源代码字符串的语法正确性，无需创建实际的脚本对象。

**参数：**
- `code`: String - 要验证的源代码

**返回值：** Dictionary 包含以下信息：
- `valid`: bool - 语法是否正确
- `error_code`: int - 错误代码
- `error`: String - 错误描述
- `error_type`: String - 错误类型
- `suggestion`: String - 修复建议
- `source_length`: int - 源代码长度

**使用示例：**
```gdscript
var yan_class = YanClass.new()
var user_code = """
extends Node
func _ready():
    print("Hello World"
"""

var result = yan_class.validate_script_syntax(user_code)
if not result["valid"]:
    print("语法错误: ", result["error_type"])
    print("修复建议: ", result["suggestion"])
```

### 3. 编译状态检测 (`get_script_compilation_status`)

获取脚本的详细编译状态和元信息。

**参数：**
- `script`: Script 对象

**返回值：** Dictionary 包含以下信息：
- `exists`: bool - 脚本是否存在
- `script_class`: String - 脚本类名
- `script_path`: String - 脚本路径
- `has_source`: bool - 是否有源代码
- `source_length`: int - 源代码长度
- `source_lines`: int - 源代码行数
- `compilation_status`: int - 编译状态
- `compilation_success`: bool - 是否编译成功
- `error_message`: String - 错误消息

### 4. 🆕 详细脚本错误检测 (`get_detailed_script_errors`)

**这是最重要的新功能！** 获取脚本的详细错误信息，包括错误行号定位。

**参数：**
- `code`: String - 要检查的源代码

**返回值：** Dictionary 包含以下信息：
- `valid`: bool - 代码是否有效
- `error_code`: int - 错误代码
- `error_type`: String - 错误类型
- `error_description`: String - 详细错误描述
- `suspected_error_line`: int - **可疑错误行号**
- `suspected_error_column`: int - **可疑错误列号**
- `suggestion`: String - 具体修复建议
- `source_length`: int - 源代码长度
- `source_lines`: int - 源代码行数

**使用示例：**
```gdscript
var yan_class = YanClass.new()
var user_code = """
extends Node
func _ready():
    print("Missing closing parenthesis"
"""

var result = yan_class.get_detailed_script_errors(user_code)
if not result["valid"]:
    print("错误类型: ", result["error_type"])
    print("可能的问题位置: 第%s行，第%s列" % [
        result["suspected_error_line"], 
        result["suspected_error_column"]
    ])
    print("建议: ", result["suggestion"])
```

### 5. 🆕 语法分析 (`analyze_script_syntax`)

深入分析源代码的语法结构，检查括号平衡、缩进等。

**参数：**
- `code`: String - 要分析的源代码

**返回值：** Dictionary 包含以下信息：
- `valid`: bool - 语法是否有效
- `total_lines`: int - 总行数
- `non_empty_lines`: int - 非空行数
- `parenthesis_balanced`: bool - 圆括号是否平衡
- `bracket_balanced`: bool - 方括号是否平衡
- `brace_balanced`: bool - 大括号是否平衡
- `syntax_issues`: Array - 语法问题列表
- `line_details`: Array - 每行的详细信息

**使用示例：**
```gdscript
var result = yan_class.analyze_script_syntax(user_code)
print("总行数: ", result["total_lines"])
print("括号平衡: ", result["parenthesis_balanced"])

if result.has("syntax_issues"):
    for issue in result["syntax_issues"]:
        print("问题: %s - %s (严重性: %s)" % [
            issue["type"], 
            issue["description"], 
            issue["severity"]
        ])
```

### 6. 🆕 错误位置定位 (`locate_error_position`)

专门用于定位错误在源代码中的具体位置。

**参数：**
- `code`: String - 源代码
- `error_type`: String - 错误类型

**返回值：** Dictionary 包含以下信息：
- `error_type`: String - 错误类型
- `error_description`: String - 错误描述
- `suspected_error_line`: int - **可疑错误行号**
- `suspected_error_column`: int - **可疑错误列号**
- `suggestion`: String - 修复建议
- `total_lines`: int - 总行数

## 错误行号定位示例

### 示例1：缺少右括号
```gdscript
var code = """
extends Node
func _ready():
    print("Hello World"  # 第4行缺少右括号
"""

var result = yan_class.get_detailed_script_errors(code)
# 结果：
# suspected_error_line: 4
# suspected_error_column: 5 (print函数开始位置)
# suggestion: "请检查第4行，确保括号匹配"
```

### 示例2：缺少冒号
```gdscript
var code = """
extends Node
func _ready()  # 第3行缺少冒号
    print("Hello")
"""

var result = yan_class.get_detailed_script_errors(code)
# 结果：
# suspected_error_line: 3
# suspected_error_column: 15 (func关键字后)
# suggestion: "请在第3行函数定义后添加冒号"
```

### 示例3：括号不匹配
```gdscript
var code = """
extends Node
func _ready():
    var test = [1, 2, 3  # 第4行缺少右方括号
    print(test)
"""

var analysis = yan_class.analyze_script_syntax(code)
# 结果：
# bracket_balanced: false
# syntax_issues: [{"type": "方括号不匹配", "severity": "high"}]
```

## 错误代码说明

| 错误代码 | 含义 | 说明 |
|---------|------|------|
| OK (0) | 成功 | 无错误 |
| ERR_PARSE_ERROR | 语法解析错误 | 括号不匹配、缺少分号等 |
| ERR_COMPILATION_FAILED | 编译失败 | 类型错误、未定义变量等 |
| ERR_INVALID_DATA | 无效数据 | 数据格式错误 |
| -1 | 自定义错误 | 脚本为空 |
| -2 | 自定义错误 | 没有源代码 |
| -3 | 自定义错误 | 无法创建脚本对象 |

## 在编程游戏中的应用

### 实时代码验证（带行号定位）

```gdscript
# 在代码编辑器中实时验证用户输入
func _on_code_text_changed():
    var code = code_edit.text
    var result = yan_class.get_detailed_script_errors(code)
    
    if result["valid"]:
        show_success_message("代码语法正确！")
    else:
        show_error_message_with_line_number(result)

func show_error_message_with_line_number(result: Dictionary):
    var error_panel = $ErrorPanel
    error_panel.get_node("ErrorType").text = "错误类型: " + result["error_type"]
    
    if result.has("suspected_error_line"):
        error_panel.get_node("ErrorLocation").text = "位置: 第%s行" % result["suspected_error_line"]
        if result.has("suspected_error_column"):
            error_panel.get_node("ErrorLocation").text += "，第%s列" % result["suspected_error_column"]
    
    error_panel.get_node("Suggestion").text = "建议: " + result["suggestion"]
    error_panel.show()
```

### 错误提示系统（增强版）

```gdscript
func show_enhanced_error_message(result: Dictionary):
    var message = "编译失败：%s" % result["error_type"]
    
    if result.has("suspected_error_line"):
        message += "\n\n可能的问题位置："
        message += "\n第%s行" % result["suspected_error_line"]
        
        if result.has("suspected_error_column"):
            message += "，第%s列" % result["suspected_error_column"]
    
    if result.has("suggestion"):
        message += "\n\n修复建议：\n%s" % result["suggestion"]
    
    # 显示错误消息
    output.text = message
```

### 代码质量评估（增强版）

```gdscript
func evaluate_code_quality_enhanced(code: String) -> Dictionary:
    var validation_result = yan_class.get_detailed_script_errors(code)
    var syntax_analysis = yan_class.analyze_script_syntax(code)
    
    var quality_score = 0
    var feedback = []
    
    # 基础分数
    if validation_result["valid"]:
        quality_score += 50  # 语法正确
        feedback.append("✓ 代码语法正确")
    else:
        feedback.append("✗ 代码存在语法错误")
        if validation_result.has("suspected_error_line"):
            feedback.append("  问题位置：第%s行" % validation_result["suspected_error_line"])
    
    # 代码结构分数
    if syntax_analysis.has("syntax_issues"):
        var issues = syntax_analysis["syntax_issues"]
        if issues.size() == 0:
            quality_score += 20  # 结构良好
            feedback.append("✓ 代码结构良好")
        else:
            feedback.append("✗ 发现 %s 个结构问题" % issues.size())
    
    # 括号平衡分数
    if syntax_analysis.has("parenthesis_balanced") and syntax_analysis["parenthesis_balanced"]:
        quality_score += 10
        feedback.append("✓ 括号匹配正确")
    else:
        feedback.append("✗ 括号不匹配")
    
    return {
        "quality_score": quality_score,
        "grade": get_grade_from_score(quality_score),
        "feedback": feedback
    }
```

## 性能注意事项

1. **避免频繁验证**：在用户输入时使用防抖，避免每次按键都进行验证
2. **缓存结果**：对于相同的代码，可以缓存验证结果
3. **异步验证**：对于长代码，考虑在后台线程中进行验证
4. **行号定位优化**：错误行号定位是计算密集型操作，建议在用户停止输入后再执行

## 最佳实践

1. **用户友好**：提供清晰的错误描述和具体的修复建议
2. **渐进式验证**：先进行基本语法检查，再进行完整编译和行号定位
3. **错误分类**：将错误按严重程度分类，优先显示重要错误
4. **学习指导**：结合错误信息提供相关的学习资源和示例
5. **行号高亮**：在代码编辑器中高亮显示错误行，提升用户体验

## 故障排除

### 常见问题

1. **编译失败但没有错误信息**
   - 检查脚本对象是否正确创建
   - 确认源代码格式正确

2. **性能问题**
   - 减少验证频率
   - 使用代码长度阈值过滤
   - 避免在每次按键时进行行号定位

3. **内存泄漏**
   - 及时释放临时脚本对象
   - 避免创建过多验证实例

4. **行号定位不准确**
   - 检查源代码的换行符格式
   - 确认代码编辑器使用的缩进方式

## 更新日志

- **v1.0**: 初始版本，支持基本脚本验证
- **v1.1**: 添加详细错误类型和建议
- **v1.2**: 优化性能和内存使用
- **v2.0**: 🆕 **重大更新！添加错误行号定位功能**
  - 新增 `get_detailed_script_errors` 方法
  - 新增 `analyze_script_syntax` 方法
  - 新增 `locate_error_position` 方法
  - 支持括号平衡检查
  - 支持错误行号和列号定位
  - 提供详细的语法分析结果
