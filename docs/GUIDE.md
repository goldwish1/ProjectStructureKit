# ProjectStructureKit 使用指南

## 目录

1. [安装](#安装)
2. [基本配置](#基本配置)
3. [生成文档](#生成文档)
4. [Git Hooks](#git-hooks)
5. [最佳实践](#最佳实践)
6. [故障排除](#故障排除)

## 安装

### Swift Package Manager

1. 在Xcode中，选择 File > Add Packages...
2. 输入包的URL：`https://github.com/yourusername/ProjectStructureKit.git`
3. 选择版本规则（建议使用 Up to Next Major）
4. 点击 Add Package

### 手动集成

1. 克隆仓库
```bash
git clone https://github.com/yourusername/ProjectStructureKit.git
```

2. 将Sources/ProjectStructureKit目录下的文件添加到你的项目中

## 基本配置

### 1. 创建配置

```swift
import ProjectStructureKit

let config = Configuration(
    // 忽略不需要记录的文件和目录
    ignoredPaths: [
        ".git",
        ".build",
        "Pods",
        "*.xcodeproj"
    ],
    // 指定文档输出路径
    outputPath: "Documentation/ARCHITECTURE.md",
    // 设置更新触发器
    updateTriggers: [.gitCommit, .manual],
    // 自定义格式化选项
    formatOptions: FormatOptions(
        indentationStyle: .spaces(4),
        includeFileSize: true,
        maxDepth: 3
    )
)
```

### 2. 初始化

```swift
do {
    let kit = try ProjectStructureKit(configuration: config)
} catch {
    print("初始化失败: \(error)")
}
```

## 生成文档

### 手动生成

```swift
do {
    try await kit.generateDocumentation()
    print("文档生成成功")
} catch {
    print("文档生成失败: \(error)")
}
```

### 检查文档状态

```swift
do {
    let status = try await kit.checkDocumentationStatus()
    if status.isUpToDate {
        print("文档是最新的")
    } else {
        print("文档需要更新")
        print("待更新的文件: \(status.pendingChanges)")
    }
} catch {
    print("状态检查失败: \(error)")
}
```

## Git Hooks

### 设置Git Hooks

```swift
do {
    try kit.setupGitHooks()
    print("Git hooks 设置成功")
} catch {
    print("Git hooks 设置失败: \(error)")
}
```

## 最佳实践

1. **合理设置忽略路径**
   - 忽略构建产物和依赖目录
   - 忽略临时文件和缓存
   - 保留重要的源代码和配置文件

2. **选择合适的更新触发时机**
   - 对于小型项目，可以使用commit触发
   - 对于大型项目，建议使用push触发
   - 考虑添加自定义触发条件

3. **文档格式化建议**
   - 设置合理的最大深度（建议3-5层）
   - 根据项目规模调整是否显示文件大小
   - 保持一致的缩进风格

## 故障排除

### 常见问题

1. **文档生成失败**
   - 检查输出路径是否有写入权限
   - 确认git仓库是否正确初始化
   - 验证忽略路径格式是否正确

2. **Git Hooks不生效**
   - 检查.git/hooks目录权限
   - 确认hooks文件是否有执行权限
   - 验证git配置是否正确

3. **性能问题**
   - 适当增加忽略路径
   - 减少文档更新频率
   - 调整最大深度限制

### 错误码说明

- `invalidConfiguration`: 配置参数无效
- `gitNotInitialized`: Git仓库未初始化
- `outputPathNotWritable`: 输出路径无法写入
- `documentationGenerationFailed`: 文档生成失败
- `gitHooksSetupFailed`: Git Hooks设置失败 