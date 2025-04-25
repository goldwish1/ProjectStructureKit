# ProjectStructureKit

ProjectStructureKit 是一个强大的工具集，用于自动生成和维护iOS项目结构文档。它包含两个主要组件：
1. Swift Package SDK - 用于在代码中集成和使用
2. CLI 工具 - 用于命令行操作和自动化

## SDK 功能特点

- 自动生成项目结构文档
- 支持自定义忽略文件/目录
- 灵活的文档格式化选项
- Git hooks自动更新支持
- 异步API支持
- iOS 13.0+ 支持

## 安装

### Swift Package Manager

将以下依赖添加到你的 `Package.swift` 文件中：

```swift
dependencies: [
    .package(url: "your-repository-url", from: "1.0.0")
]
```

### CocoaPods

将以下内容添加到你的 Podfile 中：

```ruby
pod 'ProjectStructureKit', '~> 1.0'
```

## CLI 工具使用

无需安装，直接通过 `npx` 运行：

```bash
# 使用 npx 直接运行命令
npx treeskit <命令>
```

例如：

```bash
# 初始化项目
npx treeskit init

# 生成文档
npx treeskit generate [--output <path>]

# 配置管理
npx treeskit config
```

这种方式的优点是：
- 无需全局安装，不污染用户环境
- 总是使用最新版本
- 一次性执行，不占用本地空间

## SDK 快速开始

```swift
import ProjectStructureKit

// 创建配置
let config = ProjectStructureKit.Configuration(
    ignoredPaths: [".git", "Pods"],
    outputPath: "docs/STRUCTURE.md",
    updateTriggers: [.gitCommit, .gitPush]
)

// 初始化
let kit = ProjectStructureKit(configuration: config)

// 生成文档
try await kit.generateDocumentation()

// 设置git hooks
try kit.setupGitHooks()
```

## 配置选项

### SDK 配置

```swift
// 忽略路径
let config = ProjectStructureKit.Configuration(
    ignoredPaths: [
        ".git",
        "Pods",
        "*.xcodeproj",
        "build"
    ]
)

// 格式化选项
let formatOptions = ProjectStructureKit.FormatOptions(
    includeFileSize: true,
    includeLineCount: true,
    maxDepth: 3
)

// 更新触发器
let config = ProjectStructureKit.Configuration(
    updateTriggers: [
        .manual,
        .gitCommit,
        .gitPush,
        .custom { /* 自定义触发条件 */ }
    ]
)
```

### CLI 配置文件

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
  ]
}
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

### v1.0.0
- SDK 和 CLI 工具初始版本发布
- 支持基本的文档生成功能
- 支持Git Hooks自动更新
- 提供完整的配置管理