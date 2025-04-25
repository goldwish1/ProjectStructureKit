# treeskit

treeskit 是一个命令行工具，用于自动生成和维护iOS项目结构文档。它提供了简单直观的命令行界面，帮助开发者轻松管理项目文档。

## 功能特点

- 自动生成项目结构文档
- 支持自定义忽略文件/目录
- 灵活的文档格式化选项
- Git hooks自动更新支持
- 简单易用的命令行界面

## 环境要求

### 必需组件
- Node.js >= 14.0.0
- npm >= 6.0.0
- tree命令行工具

### 操作系统支持
- macOS
- Linux
- Windows (需要额外配置)

## 使用方法

无需安装，直接通过 `npx` 运行：

```bash
# 使用 npx 直接运行命令
npx treeskit <命令>
```

### 可用命令

```bash
# 初始化项目
npx treeskit init

# 生成文档
npx treeskit generate [--output <path>]

# 配置管理
npx treeskit config
```

### 命令详细说明

1. **init**
   - 初始化项目配置
   - 创建默认的配置文件
   - 设置Git hooks（可选）

   交互式配置项：
   - 项目名称（必填）
   - Git Hooks启用状态（可选，默认：是）

   示例：
   ```bash
   $ npx treeskit init
   ? 请输入项目名称: MyApp
   ? 是否启用Git Hooks来自动更新文档? Yes
   ✓ 配置文件已创建
   ✓ Git Hooks已配置
   ```

2. **generate**
   - 生成项目结构文档
   - 支持自定义输出路径
   - 可选择是否包含文件大小和行数信息

   选项：
   - `-o, --output <path>` - 指定文档输出路径（默认：docs）

   示例：
   ```bash
   # 使用默认输出路径
   $ npx treeskit generate

   # 指定输出路径
   $ npx treeskit generate -o ./docs/structure
   ```

3. **config**
   - 管理工具配置
   - 设置忽略规则
   - 配置文档格式

   配置项：
   - 项目名称：项目的显示名称
   - 输出路径：文档生成位置（默认：docs）
   - Git Hooks：是否启用自动更新（默认：true）
   - 忽略路径：不包含在文档中的路径

## 配置文件

`.projectstructure.json` 配置文件结构：

```json
{
  "projectName": "项目名称",
  "useGitHooks": true,
  "outputPath": "docs",
  "ignorePaths": [
    "node_modules",
    ".git",
    "build",
    "DerivedData"
  ],
  "format": {
    "includeFileSize": true,
    "includeLineCount": true,
    "maxDepth": 3
  }
}
```

### 配置项说明

- **projectName**: 项目名称，将显示在生成的文档中
- **useGitHooks**: 是否启用Git hooks自动更新功能
- **outputPath**: 文档输出路径
- **ignorePaths**: 需要忽略的文件或目录列表
- **format**: 文档格式化选项
  - **includeFileSize**: 是否包含文件大小信息
  - **includeLineCount**: 是否包含文件行数信息
  - **maxDepth**: 目录结构最大深度

## 错误处理

### 常见错误码
- `ENOENT`: 文件或目录不存在
- `EACCES`: 权限不足
- `EINVAL`: 无效的参数

### 错误信息示例
```bash
# 配置文件不存在
Error: 未找到配置文件，请先运行 npx treeskit init

# 输出目录无写入权限
Error: 无法写入文档，请检查目录权限

# tree命令未安装
Error: 未找到tree命令，请先安装
```

## 最佳实践

1. **定期更新文档**
   - 推荐启用Git Hooks自动更新
   - 在重要更改后手动运行generate命令

2. **配置忽略路径**
   - 添加临时文件目录
   - 添加构建产物目录
   - 添加依赖目录

3. **文档位置**
   - 建议将文档放在专门的文档目录
   - 确保文档目录被版本控制追踪

## 常见问题

1. **找不到tree命令**
   ```bash
   # macOS安装tree
   brew install tree
   
   # Linux安装tree
   sudo apt-get install tree  # Ubuntu/Debian
   sudo yum install tree      # CentOS/RHEL
   ```

2. **配置文件不存在**
   - 确保先运行 `npx treeskit init`
   - 检查是否在正确的项目目录中

3. **Git Hooks不生效**
   - 确保项目是Git仓库
   - 检查 `.git/hooks` 目录权限
   - 重新运行 `npx treeskit init`

## 许可证

MIT

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 更新日志

### v2.0.0
- 移除SDK相关功能，专注于CLI工具
- 优化命令行界面和用户体验
- 更新文档和配置选项
- 简化项目结构