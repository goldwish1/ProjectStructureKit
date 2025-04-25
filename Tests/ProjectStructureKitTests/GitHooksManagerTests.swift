import XCTest
import PathKit
@testable import ProjectStructureKit

final class GitHooksManagerTests: XCTestCase {
    private var tempDirectory: Path!
    private var gitDirectory: Path!
    private var hooksManager: GitHooksManager!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // 创建临时目录
        tempDirectory = Path.temporary + "GitHooksTests"
        try? tempDirectory.delete()
        try tempDirectory.mkdir()
        
        // 创建Git仓库结构
        gitDirectory = tempDirectory + ".git"
        try gitDirectory.mkdir()
        try (gitDirectory + "hooks").mkdir()
        
        // 初始化hooks管理器
        hooksManager = try GitHooksManager(gitRoot: tempDirectory.string)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        try? tempDirectory.delete()
    }
    
    func testInstallHooks() throws {
        // 安装hooks
        try hooksManager.installHooks([.preCommit, .prePush])
        
        // 验证hooks是否已安装
        XCTAssertTrue(hooksManager.isHookInstalled(.preCommit))
        XCTAssertTrue(hooksManager.isHookInstalled(.prePush))
        
        // 验证hook文件
        let preCommitPath = gitDirectory + "hooks/pre-commit"
        let prePushPath = gitDirectory + "hooks/pre-push"
        
        XCTAssertTrue(preCommitPath.exists)
        XCTAssertTrue(prePushPath.exists)
        
        // 验证hook内容
        let preCommitContent = try String(contentsOf: preCommitPath.url, encoding: .utf8)
        XCTAssertTrue(preCommitContent.contains("#!/bin/sh"))
        XCTAssertTrue(preCommitContent.contains("ProjectStructureKit"))
    }
    
    func testUninstallHooks() throws {
        // 先安装hooks
        try hooksManager.installHooks([.preCommit, .prePush])
        
        // 卸载hooks
        try hooksManager.uninstallHooks([.preCommit])
        
        // 验证hooks状态
        XCTAssertFalse(hooksManager.isHookInstalled(.preCommit))
        XCTAssertTrue(hooksManager.isHookInstalled(.prePush))
    }
    
    func testUpdateInstalledHooks() async throws {
        // 先安装hooks
        try hooksManager.installHooks([.preCommit])
        
        // 记录原始文件修改时间
        let hookPath = gitDirectory + "hooks/pre-commit"
        let attributes = try FileManager.default.attributesOfItem(atPath: hookPath.string)
        let originalModTime = attributes[.modificationDate] as! Date
        
        // 等待一秒确保修改时间会不同
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 更新hooks
        try hooksManager.updateInstalledHooks()
        
        // 验证文件已更新
        let newAttributes = try FileManager.default.attributesOfItem(atPath: hookPath.string)
        let newModTime = newAttributes[.modificationDate] as! Date
        XCTAssertNotEqual(originalModTime, newModTime)
    }
    
    func testGetInstalledHooks() throws {
        // 初始状态应该没有安装的hooks
        XCTAssertTrue(hooksManager.getInstalledHooks().isEmpty)
        
        // 安装hooks
        try hooksManager.installHooks([.preCommit, .postMerge])
        
        // 验证已安装的hooks
        let installedHooks = hooksManager.getInstalledHooks()
        XCTAssertEqual(installedHooks.count, 2)
        XCTAssertTrue(installedHooks.contains(.preCommit))
        XCTAssertTrue(installedHooks.contains(.postMerge))
    }
    
    func testInitializationWithInvalidGitRoot() {
        let invalidPath = Path.temporary + "NonexistentDirectory"
        XCTAssertThrowsError(try GitHooksManager(gitRoot: invalidPath.string)) { error in
            XCTAssertTrue(error is GitHooksManager.HookError)
            if case .gitDirectoryNotFound = error as? GitHooksManager.HookError {
                // 预期的错误
            } else {
                XCTFail("Unexpected error type")
            }
        }
    }
} 