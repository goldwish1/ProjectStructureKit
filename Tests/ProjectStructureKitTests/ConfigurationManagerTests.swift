import XCTest
import PathKit
@testable import ProjectStructureKit

final class ConfigurationManagerTests: XCTestCase {
    private var tempDirectory: Path!
    private var configManager: ConfigurationManager!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // 创建临时目录
        tempDirectory = Path.temporary + "ConfigTests"
        try? tempDirectory.delete()
        try tempDirectory.mkdir()
        
        // 初始化配置管理器
        configManager = ConfigurationManager(configPath: (tempDirectory + ".project-structure-kit.json").string)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        try? tempDirectory.delete()
    }
    
    func testCreateDefaultConfiguration() throws {
        // 创建默认配置
        try configManager.createDefaultConfiguration()
        
        // 验证配置文件存在
        let configPath = tempDirectory + ".project-structure-kit.json"
        XCTAssertTrue(configPath.exists)
        
        // 加载并验证配置
        let config = try configManager.loadConfiguration()
        XCTAssertEqual(config.outputPath, "docs/STRUCTURE.md")
        XCTAssertEqual(config.ignoredPaths.count, 5)
        XCTAssertEqual(config.updateTriggers.count, 1)
        XCTAssertEqual(config.updateTriggers.first?.description, "gitCommit")
    }
    
    func testSaveAndLoadConfiguration() throws {
        // 创建测试配置
        let config = ProjectStructureKit.Configuration(
            ignoredPaths: ["test", "*.tmp"],
            outputPath: "output.md",
            updateTriggers: [.manual, .gitPush],
            formatOptions: .init(includeFileSize: false, includeLineCount: true, maxDepth: 3)
        )
        
        // 保存配置
        try configManager.saveConfiguration(config)
        
        // 加载配置
        let loadedConfig = try configManager.loadConfiguration()
        
        // 验证配置
        XCTAssertEqual(loadedConfig.ignoredPaths, config.ignoredPaths)
        XCTAssertEqual(loadedConfig.outputPath, config.outputPath)
        XCTAssertEqual(loadedConfig.updateTriggers.map(\.description), config.updateTriggers.map(\.description))
        XCTAssertEqual(loadedConfig.formatOptions.includeFileSize, config.formatOptions.includeFileSize)
        XCTAssertEqual(loadedConfig.formatOptions.includeLineCount, config.formatOptions.includeLineCount)
        XCTAssertEqual(loadedConfig.formatOptions.maxDepth, config.formatOptions.maxDepth)
    }
    
    func testValidateConfiguration() {
        // 测试有效配置
        let validConfig = ProjectStructureKit.Configuration(
            ignoredPaths: ["test"],
            outputPath: "output.md",
            updateTriggers: [.manual]
        )
        let validResult = configManager.validateConfiguration(validConfig)
        XCTAssertTrue(validResult.isValid)
        XCTAssertTrue(validResult.errors.isEmpty)
        
        // 测试无效配置
        let invalidConfig = ProjectStructureKit.Configuration(
            ignoredPaths: ["", "test"],
            outputPath: "",
            updateTriggers: [.manual],
            formatOptions: .init(maxDepth: -1)
        )
        let invalidResult = configManager.validateConfiguration(invalidConfig)
        XCTAssertFalse(invalidResult.isValid)
        XCTAssertEqual(invalidResult.errors.count, 3)
    }
    
    func testLoadNonexistentConfiguration() {
        XCTAssertThrowsError(try configManager.loadConfiguration()) { error in
            XCTAssertTrue(error is ConfigurationManager.ConfigError)
            if case .fileNotFound = error as? ConfigurationManager.ConfigError {
                // 预期的错误
            } else {
                XCTFail("Unexpected error type")
            }
        }
    }
} 