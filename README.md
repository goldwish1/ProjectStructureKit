# ProjectStructureKit

ProjectStructureKit 是一个用于自动生成和维护iOS项目结构文档的Swift Package。它可以帮助开发者自动生成项目结构文档，并通过git hooks保持文档的实时更新。

## 功能特点

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

## 快速开始

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

### 忽略路径

```swift
let config = ProjectStructureKit.Configuration(
    ignoredPaths: [
        ".git",
        "Pods",
        "*.xcodeproj",
        "build"
    ]
)
```

### 格式化选项

```swift
let formatOptions = ProjectStructureKit.FormatOptions(
    includeFileSize: true,
    includeLineCount: true,
    maxDepth: 3
)
```

### 更新触发器

```swift
let config = ProjectStructureKit.Configuration(
    updateTriggers: [
        .manual,
        .gitCommit,
        .gitPush,
        .custom { /* 自定义触发条件 */ }
    ]
)
```

## 许可证

MIT

## 作者

[Your Name]

## 贡献

欢迎提交 Issue 和 Pull Request！ 