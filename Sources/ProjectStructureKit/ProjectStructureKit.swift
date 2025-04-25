// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ShellOut
import PathKit

public class ProjectStructureKit {
    /// 配置选项
    public struct Configuration: Equatable {
        public var ignoredPaths: [String]
        public var outputPath: String
        public var updateTriggers: [UpdateTrigger]
        public var formatOptions: FormatOptions
        
        public init(
            ignoredPaths: [String] = [],
            outputPath: String = "README.md",
            updateTriggers: [UpdateTrigger] = [.manual],
            formatOptions: FormatOptions = .default
        ) {
            self.ignoredPaths = ignoredPaths
            self.outputPath = outputPath
            self.updateTriggers = updateTriggers
            self.formatOptions = formatOptions
        }
        
        public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
            return lhs.ignoredPaths == rhs.ignoredPaths &&
                   lhs.outputPath == rhs.outputPath &&
                   lhs.updateTriggers.map(\.description) == rhs.updateTriggers.map(\.description) &&
                   lhs.formatOptions == rhs.formatOptions
        }
    }
    
    /// 更新触发器类型
    public enum UpdateTrigger: Equatable {
        case manual
        case gitCommit
        case gitPush
        case custom(trigger: () -> Bool)
        
        public var description: String {
            switch self {
            case .manual: return "manual"
            case .gitCommit: return "gitCommit"
            case .gitPush: return "gitPush"
            case .custom: return "custom"
            }
        }
        
        public static func == (lhs: UpdateTrigger, rhs: UpdateTrigger) -> Bool {
            return lhs.description == rhs.description
        }
    }
    
    /// 格式化选项
    public struct FormatOptions: Equatable {
        public var includeFileSize: Bool
        public var includeLineCount: Bool
        public var maxDepth: Int?
        
        public static let `default` = FormatOptions(
            includeFileSize: true,
            includeLineCount: true,
            maxDepth: nil
        )
        
        public init(
            includeFileSize: Bool = true,
            includeLineCount: Bool = true,
            maxDepth: Int? = nil
        ) {
            self.includeFileSize = includeFileSize
            self.includeLineCount = includeLineCount
            self.maxDepth = maxDepth
        }
    }
    
    private let configuration: Configuration
    private let generator: ProjectStructureGenerator
    private let formatter: MarkdownFormatter
    private let configManager: ConfigurationManager
    private var hooksManager: GitHooksManager?
    
    public init(configuration: Configuration = Configuration(), configPath: String? = nil) {
        self.configManager = ConfigurationManager(configPath: configPath)
        
        // 尝试加载配置文件
        if let loadedConfig = try? configManager.loadConfiguration() {
            self.configuration = loadedConfig
        } else {
            self.configuration = configuration
            try? configManager.saveConfiguration(configuration)
        }
        
        // 初始化生成器
        self.generator = ProjectStructureGenerator(
            rootPath: FileManager.default.currentDirectoryPath,
            ignoredPaths: self.configuration.ignoredPaths,
            maxDepth: self.configuration.formatOptions.maxDepth,
            includeFileSize: self.configuration.formatOptions.includeFileSize,
            includeLineCount: self.configuration.formatOptions.includeLineCount
        )
        
        // 初始化格式化器
        self.formatter = MarkdownFormatter(
            options: .init(
                showFileSize: self.configuration.formatOptions.includeFileSize,
                showLineCount: self.configuration.formatOptions.includeLineCount
            )
        )
        
        // 初始化Git Hooks管理器
        self.hooksManager = try? GitHooksManager()
    }
    
    /// 生成文档
    public func generateDocumentation() async throws {
        // 生成项目结构
        let structure = try generator.generateStructure()
        
        // 格式化为Markdown
        let markdown = formatter.format(structure: structure)
        
        // 写入文件
        try markdown.write(
            toFile: configuration.outputPath,
            atomically: true,
            encoding: .utf8
        )
    }
    
    /// 设置git hooks
    public func setupGitHooks() throws {
        guard let manager = hooksManager else {
            throw GitHooksManager.HookError.gitDirectoryNotFound
        }
        
        let hookTypes = configuration.updateTriggers.compactMap { trigger -> GitHooksManager.HookType? in
            switch trigger {
            case .gitCommit:
                return .preCommit
            case .gitPush:
                return .prePush
            default:
                return nil
            }
        }
        
        try manager.installHooks(hookTypes)
    }
    
    /// 移除git hooks
    public func removeGitHooks() throws {
        guard let manager = hooksManager else {
            throw GitHooksManager.HookError.gitDirectoryNotFound
        }
        
        try manager.uninstallHooks(GitHooksManager.HookType.allCases)
    }
    
    /// 更新git hooks
    public func updateGitHooks() throws {
        guard let manager = hooksManager else {
            throw GitHooksManager.HookError.gitDirectoryNotFound
        }
        
        try manager.updateInstalledHooks()
    }
    
    /// 获取已安装的git hooks
    public func getInstalledHooks() -> [String] {
        guard let manager = hooksManager else {
            return []
        }
        
        return manager.getInstalledHooks().map(\.rawValue)
    }
    
    /// 检查文档状态
    public func checkDocumentationStatus() async throws -> DocumentationStatus {
        do {
            let currentStructure = try generator.generateStructure()
            let currentMarkdown = formatter.format(structure: currentStructure)
            
            let existingMarkdown = try String(
                contentsOfFile: configuration.outputPath,
                encoding: .utf8
            )
            
            return currentMarkdown == existingMarkdown
                ? .upToDate
                : .needsUpdate
        } catch {
            return .error(error)
        }
    }
    
    /// 更新配置
    public func updateConfiguration(_ newConfig: Configuration) throws {
        // 验证新配置
        let validationResult = configManager.validateConfiguration(newConfig)
        guard validationResult.isValid else {
            throw ConfigError.invalidConfiguration(validationResult.errors)
        }
        
        // 保存配置
        try configManager.saveConfiguration(newConfig)
    }
}

/// 文档状态
public enum DocumentationStatus {
    case upToDate
    case needsUpdate
    case error(Error)
}

/// 配置错误
public enum ConfigError: Error {
    case invalidConfiguration([String])
}
