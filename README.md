# treeskit

treeskit 是一个命令行工具，用于自动生成和维护iOS项目结构文档。它提供了简单直观的命令行界面，帮助开发者轻松管理项目文档。

## ⚠️ 重要：前置依赖安装

在使用 treeskit 之前，请确保您的系统已安装以下必需组件：

1. **Node.js 和 npm**
   - Node.js >= 14.0.0
   - npm >= 6.0.0

2. **tree 命令行工具**（必需）
   ```bash
   # 在 macOS 上安装
   brew install tree
   
   # 在 Linux 上安装
   sudo apt-get install tree  # Ubuntu/Debian
   sudo yum install tree      # CentOS/RHEL
   
   # 验证安装
   tree --version  # 如果正确安装，会显示版本号
   ```

### 操作系统支持
- macOS
- Linux
- Windows (需要额外配置)

## 使用方法

treeskit 提供两种使用方式：

### 1. 使用 npx（推荐新手用户）
无需安装，直接通过 `npx` 运行：

```bash
# 使用 npx 直接运行命令
npx treeskit <命令>

# 例如：
npx treeskit init
npx treeskit generate
```

### 2. 全局安装（推荐经常使用的用户）
```bash
# 全局安装
npm install -g treeskit

# 安装后可以直接使用命令
treeskit <命令>
```

注意：如果遇到 "command not found: treeskit" 错误：
1. 确保已正确全局安装：`npm install -g treeskit`
2. 检查 npm 全局路径是否在 PATH 中：
   ```bash
   # 查看 npm 全局安装路径
   npm config get prefix
   
   # 确保该路径在 PATH 环境变量中
   echo $PATH
   ```
3. 重新打开终端
4. 或改用 npx 方式运行命令

### 可用命令

```bash
# 初始化项目
treeskit init    # 或 npx treeskit init

# 生成文档
treeskit generate [--output <path>]    # 或 npx treeskit generate

# 配置管理
treeskit config    # 或 npx treeskit config

# Git Hooks管理
treeskit hooks <enable|disable|status>    # 或 npx treeskit hooks
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

4. **hooks**
   - 管理Git Hooks功能
   - 支持启用/禁用自动更新
   - 查看当前状态

   子命令：
   - `enable` - 启用Git Hooks
   - `disable` - 禁用Git Hooks
   - `status` - 查看当前状态

   示例：
   ```bash
   # 启用Git Hooks
   $ npx treeskit hooks enable

   # 禁用Git Hooks
   $ npx treeskit hooks disable

   # 查看状态
   $ npx treeskit hooks status
   ```

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

## Git Hooks功能

treeskit使用原生Git hooks来实现文档的自动更新。当启用此功能时：

1. **自动更新**
   - 在每次提交前自动更新文档
   - 自动将更新后的文档添加到提交中

2. **安全性**
   - 自动备份现有的pre-commit hook
   - 在禁用功能时恢复原有hook

3. **灵活控制**
   - 可随时启用/禁用功能
   - 支持查看当前状态
   - 通过配置或命令行管理

4. **错误处理**
   - 优雅处理非Git仓库情况
   - 处理权限问题
   - 提供清晰的错误提示

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

# Git相关错误
Error: 当前目录不是git仓库，请先初始化git
Error: Git Hooks配置失败，请检查权限
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

4. **Git Hooks管理**
   - 在项目初始化时决定是否启用
   - 定期检查hooks状态
   - 在团队中统一使用状态

## 常见问题

1. **生成文档失败：tree command not found**
   ```bash
   # 错误信息
   /bin/sh: tree: Command not found
   生成文档失败: Command failed: tree -L 3 -I "node_modules|.git|build|DerivedData"
   
   # 解决方案：
   # 1. 在 macOS 上安装
   brew install tree
   
   # 2. 在 Linux 上安装
   sudo apt-get install tree  # Ubuntu/Debian
   sudo yum install tree      # CentOS/RHEL
   
   # 3. 安装后验证
   tree --version
   
   # 4. 验证成功后重新运行
   treeskit generate
   ```

2. **命令未找到 (command not found: treeskit)**
   ```bash
   # 解决方案 1：使用 npx 方式运行（推荐新手）
   npx treeskit <命令>
   
   # 解决方案 2：全局安装（推荐经常使用）
   npm install -g treeskit
   
   # 如果全局安装后仍然报错，请检查：
   # 1. 检查安装是否成功
   npm list -g treeskit
   
   # 2. 检查 npm 全局路径
   npm config get prefix
   
   # 3. 确认该路径在 PATH 中
   echo $PATH
   
   # 4. 重启终端后重试
   ```

3. **配置文件不存在**
   - 确保先运行 `npx treeskit init`
   - 检查是否在正确的项目目录中

4. **Git Hooks不生效**
   - 确保项目是Git仓库
   - 检查是否存在其他 Git Hooks 管理工具（如 husky）：
     ```bash
     # 检查是否被其他工具接管
     git config --get core.hooksPath
     
     # 如果输出不为空，说明被其他工具接管，需要：
     # 1. 要么卸载其他工具
     # 2. 要么执行以下命令恢复原生 hooks：
     git config --unset core.hooksPath
     ```
   - 检查 `.git/hooks` 目录权限
   - 使用 `treeskit hooks status` 检查状态
   - 尝试重新启用: `treeskit hooks enable`

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
- 添加Git Hooks管理命令