import Foundation
import PathKit

/// 配置管理器
public class ConfigurationManager {
    /// 配置文件名
    public static let defaultConfigFileName = ".project-structure-kit.json"
    
    /// 配置错误
    public enum ConfigError: Error {
        case fileNotFound
        case invalidFormat
        case invalidValue(String)
        case saveFailed(Error)
    }
    
    /// 配置验证结果
    public struct ValidationResult {
        public let isValid: Bool
        public let errors: [String]
        
        public static let valid = ValidationResult(isValid: true, errors: [])
    }
    
    private let configPath: Path
    private var currentConfig: ProjectStructureKit.Configuration
    
    /// 初始化配置管理器
    /// - Parameter configPath: 配置文件路径，默认为当前目录下的.project-structure-kit.json
    public init(configPath: String? = nil) {
        self.configPath = Path(configPath ?? ConfigurationManager.defaultConfigFileName)
        self.currentConfig = .init()
    }
    
    /// 加载配置
    public func loadConfiguration() throws -> ProjectStructureKit.Configuration {
        guard configPath.exists else {
            throw ConfigError.fileNotFound
        }
        
        let data = try Data(contentsOf: configPath.url)
        let decoder = JSONDecoder()
        
        do {
            let config = try decoder.decode(ConfigurationDTO.self, from: data)
            currentConfig = config.toConfiguration()
            return currentConfig
        } catch {
            throw ConfigError.invalidFormat
        }
    }
    
    /// 保存配置
    public func saveConfiguration(_ config: ProjectStructureKit.Configuration) throws {
        let dto = ConfigurationDTO(from: config)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(dto)
            try data.write(to: configPath.url)
            currentConfig = config
        } catch {
            throw ConfigError.saveFailed(error)
        }
    }
    
    /// 验证配置
    public func validateConfiguration(_ config: ProjectStructureKit.Configuration) -> ValidationResult {
        var errors = [String]()
        
        // 验证输出路径
        if config.outputPath.isEmpty {
            errors.append("输出路径不能为空")
        }
        
        // 验证忽略路径格式
        for path in config.ignoredPaths {
            if path.isEmpty {
                errors.append("忽略路径不能为空")
            }
        }
        
        // 验证格式化选项
        if let maxDepth = config.formatOptions.maxDepth, maxDepth < 0 {
            errors.append("最大深度不能为负数")
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    /// 创建默认配置文件
    public func createDefaultConfiguration() throws {
        let defaultConfig = ProjectStructureKit.Configuration(
            ignoredPaths: [
                ".git",
                ".build",
                "*.xcodeproj",
                "Pods",
                "Carthage"
            ],
            outputPath: "docs/STRUCTURE.md",
            updateTriggers: [.gitCommit],
            formatOptions: .default
        )
        
        try saveConfiguration(defaultConfig)
    }
}

/// 配置数据传输对象
private struct ConfigurationDTO: Codable {
    let ignoredPaths: [String]
    let outputPath: String
    let updateTriggers: [String]
    let formatOptions: FormatOptionsDTO
    
    struct FormatOptionsDTO: Codable {
        let includeFileSize: Bool
        let includeLineCount: Bool
        let maxDepth: Int?
    }
    
    init(from config: ProjectStructureKit.Configuration) {
        self.ignoredPaths = config.ignoredPaths
        self.outputPath = config.outputPath
        self.updateTriggers = config.updateTriggers.map { trigger -> String in
            switch trigger {
            case .manual: return "manual"
            case .gitCommit: return "gitCommit"
            case .gitPush: return "gitPush"
            case .custom: return "custom"
            }
        }
        self.formatOptions = FormatOptionsDTO(
            includeFileSize: config.formatOptions.includeFileSize,
            includeLineCount: config.formatOptions.includeLineCount,
            maxDepth: config.formatOptions.maxDepth
        )
    }
    
    func toConfiguration() -> ProjectStructureKit.Configuration {
        let triggers: [ProjectStructureKit.UpdateTrigger] = updateTriggers.compactMap { str in
            switch str {
            case "manual": return .manual
            case "gitCommit": return .gitCommit
            case "gitPush": return .gitPush
            default: return nil
            }
        }
        
        let options = ProjectStructureKit.FormatOptions(
            includeFileSize: formatOptions.includeFileSize,
            includeLineCount: formatOptions.includeLineCount,
            maxDepth: formatOptions.maxDepth
        )
        
        return ProjectStructureKit.Configuration(
            ignoredPaths: ignoredPaths,
            outputPath: outputPath,
            updateTriggers: triggers,
            formatOptions: options
        )
    }
} 