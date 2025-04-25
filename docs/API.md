# ProjectStructureKit API 文档

## 核心类

### ProjectStructureKit

主类，用于初始化和管理项目结构文档生成功能。

```swift
public class ProjectStructureKit {
    public init(configuration: Configuration) throws
    
    // 生成文档
    public func generateDocumentation() async throws
    
    // 设置Git Hooks
    public func setupGitHooks() throws
    
    // 检查文档状态
    public func checkDocumentationStatus() async throws -> DocumentationStatus
}
```

### Configuration

配置类，用于设置ProjectStructureKit的行为。

```swift
public struct Configuration {
    public init(
        ignoredPaths: [String] = [],
        outputPath: String = "Documentation/ARCHITECTURE.md",
        updateTriggers: [UpdateTrigger] = [.gitCommit],
        formatOptions: FormatOptions = FormatOptions()
    )
    
    public var ignoredPaths: [String]
    public var outputPath: String
    public var updateTriggers: [UpdateTrigger]
    public var formatOptions: FormatOptions
}
```

### FormatOptions

文档格式化选项。

```swift
public struct FormatOptions {
    public init(
        indentationStyle: IndentationStyle = .spaces(2),
        includeFileSize: Bool = true,
        maxDepth: Int = 5
    )
    
    public var indentationStyle: IndentationStyle
    public var includeFileSize: Bool
    public var maxDepth: Int
}
```

### UpdateTrigger

定义何时更新文档。

```swift
public enum UpdateTrigger {
    case manual
    case gitCommit
    case gitPush
    case custom(() -> Bool)
}
```

### DocumentationStatus

文档状态信息。

```swift
public struct DocumentationStatus {
    public let isUpToDate: Bool
    public let lastUpdateTime: Date
    public let pendingChanges: [String]
}
```

## 错误处理

```swift
public enum ProjectStructureKitError: Error {
    case invalidConfiguration
    case gitNotInitialized
    case outputPathNotWritable
    case documentationGenerationFailed
    case gitHooksSetupFailed
}
```

## 使用示例

### 基本用法

```swift
// 创建配置
let config = Configuration(
    ignoredPaths: [".git", ".build", "*.xcodeproj"],
    outputPath: "Documentation/ARCHITECTURE.md",
    updateTriggers: [.gitCommit, .manual]
)

// 初始化
do {
    let kit = try ProjectStructureKit(configuration: config)
    try kit.setupGitHooks()
    try await kit.generateDocumentation()
} catch {
    print("Error: \(error)")
}
```

### 自定义格式化

```swift
let formatOptions = FormatOptions(
    indentationStyle: .spaces(4),
    includeFileSize: true,
    maxDepth: 3
)

let config = Configuration(
    formatOptions: formatOptions
)
```

### 自定义更新触发器

```swift
let config = Configuration(
    updateTriggers: [
        .gitCommit,
        .custom { 
            // 自定义触发条件
            return true
        }
    ]
)
``` 