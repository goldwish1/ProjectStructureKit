# ProjectStructureKit CLI 命令参考

## 命令列表

### `init`

初始化ProjectStructureKit。

```bash
project-structure init
```

#### 功能
- 创建配置文件
- 设置项目基本信息
- 配置Git Hooks（可选）

#### 交互式配置项
- 项目名称（必填）
- Git Hooks启用状态（可选，默认：是）

#### 示例
```bash
$ project-structure init
? 请输入项目名称: MyApp
? 是否启用Git Hooks来自动更新文档? Yes
✓ 配置文件已创建
✓ Git Hooks已配置

初始化完成！现在您可以使用以下命令：
  project-structure generate - 生成项目结构文档
  project-structure config - 修改配置
```

### `generate`

生成项目结构文档。

```bash
project-structure generate [options]
```

#### 选项
- `-o, --output <path>` - 指定文档输出路径

#### 功能
- 扫描项目目录结构
- 生成树形图
- 创建Markdown文档
- 添加目录说明

#### 示例
```bash
# 使用默认输出路径
$ project-structure generate

# 指定输出路径
$ project-structure generate -o ./docs/structure

# 输出结果
✓ 文档已生成：./docs/structure/PROJECT_STRUCTURE.md
```

### `config`

配置ProjectStructureKit设置。

```bash
project-structure config
```

#### 功能
- 修改现有配置
- 更新配置文件
- 重新配置Git Hooks

#### 配置项
1. 项目名称
   - 类型：字符串
   - 说明：项目的显示名称

2. 输出路径
   - 类型：字符串
   - 说明：文档生成位置
   - 默认值：`docs`

3. Git Hooks
   - 类型：布尔值
   - 说明：是否启用自动更新
   - 默认值：`true`

4. 忽略路径
   - 类型：字符串数组
   - 说明：不包含在文档中的路径
   - 默认值：`["node_modules", ".git", "build", "DerivedData"]`

#### 示例
```bash
$ project-structure config
? 项目名称: MyApp
? 文档输出路径: docs
? 是否启用Git Hooks: Yes
? 忽略的路径（用逗号分隔）: node_modules,.git,build,DerivedData
✓ 配置已更新
```

## 错误处理

### 常见错误码
- `ENOENT`: 文件或目录不存在
- `EACCES`: 权限不足
- `EINVAL`: 无效的参数

### 错误信息示例
```bash
# 配置文件不存在
Error: 未找到配置文件，请先运行 project-structure init

# 输出目录无写入权限
Error: 无法写入文档，请检查目录权限

# tree命令未安装
Error: 未找到tree命令，请先安装
```

## 环境要求

### 必需组件
- Node.js >= 14.0.0
- npm >= 6.0.0
- tree命令行工具

### 操作系统支持
- macOS
- Linux
- Windows (需要额外配置) 