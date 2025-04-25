import Foundation
import ProjectStructureKit

// 创建配置
let config = Configuration(
    ignoredPaths: [".git", ".build", "*.xcodeproj"],
    outputPath: "Documentation/ARCHITECTURE.md",
    updateTriggers: [.gitCommit, .manual],
    formatOptions: FormatOptions(
        indentationStyle: .spaces(4),
        includeFileSize: true,
        maxDepth: 3
    )
)

// 初始化ProjectStructureKit
do {
    let kit = try ProjectStructureKit(configuration: config)
    
    // 设置Git Hooks
    try kit.setupGitHooks()
    print("✅ Git hooks 设置成功")
    
    // 生成文档
    try await kit.generateDocumentation()
    print("✅ 项目结构文档生成成功")
    
    // 检查文档状态
    let status = try await kit.checkDocumentationStatus()
    print("📝 文档状态: \(status)")
} catch {
    print("❌ 错误: \(error)")
} 