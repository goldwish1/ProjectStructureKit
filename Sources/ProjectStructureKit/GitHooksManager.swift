import Foundation
import PathKit
import ShellOut

/// Git Hooks管理器
public class GitHooksManager {
    /// Hook类型
    public enum HookType: String, CaseIterable {
        case preCommit = "pre-commit"
        case prePush = "pre-push"
        case postMerge = "post-merge"
        case postCheckout = "post-checkout"
        
        var scriptContent: String {
            """
            #!/bin/sh
            
            # ProjectStructureKit自动生成的hook脚本
            # 请勿手动修改
            
            # 获取项目根目录
            PROJECT_ROOT=$(git rev-parse --show-toplevel)
            cd "$PROJECT_ROOT"
            
            # 检查是否需要更新文档
            if swift run project-structure-kit check > /dev/null 2>&1; then
                echo "📝 正在更新项目结构文档..."
                if swift run project-structure-kit generate; then
                    # 如果是pre-commit hook，将更新后的文档添加到暂存区
                    if [ "\(rawValue)" = "pre-commit" ]; then
                        git add "$(swift run project-structure-kit config get outputPath)"
                    fi
                    echo "✅ 项目结构文档已更新"
                else
                    echo "❌ 文档更新失败"
                    exit 1
                fi
            else
                echo "✨ 项目结构文档已是最新"
            fi
            
            exit 0
            """
        }
    }
    
    /// Hook错误
    public enum HookError: Error {
        case gitDirectoryNotFound
        case hookCreationFailed(String)
        case hookDeletionFailed(String)
        case hookUpdateFailed(String)
        case invalidHookType(String)
        
        public var localizedDescription: String {
            switch self {
            case .gitDirectoryNotFound:
                return "未找到.git目录，请确保在Git仓库中运行"
            case .hookCreationFailed(let hook):
                return "创建\(hook)钩子失败"
            case .hookDeletionFailed(let hook):
                return "删除\(hook)钩子失败"
            case .hookUpdateFailed(let hook):
                return "更新\(hook)钩子失败"
            case .invalidHookType(let type):
                return "无效的钩子类型: \(type)"
            }
        }
    }
    
    private let gitRoot: Path
    private let hooksDir: Path
    
    /// 初始化Git Hooks管理器
    /// - Parameter gitRoot: Git仓库根目录路径，默认为当前目录
    public init(gitRoot: String? = nil) throws {
        let rootPath = gitRoot.map { Path($0) } ?? Path.current
        self.gitRoot = rootPath
        
        // 验证.git目录是否存在
        let gitDir = rootPath + ".git"
        guard gitDir.exists else {
            throw HookError.gitDirectoryNotFound
        }
        
        self.hooksDir = gitDir + "hooks"
        try? hooksDir.mkdir() // 确保hooks目录存在
    }
    
    /// 安装指定的Git hooks
    /// - Parameter types: 要安装的hook类型数组
    public func installHooks(_ types: [HookType]) throws {
        for type in types {
            try installHook(type)
        }
    }
    
    /// 卸载指定的Git hooks
    /// - Parameter types: 要卸载的hook类型数组
    public func uninstallHooks(_ types: [HookType]) throws {
        for type in types {
            try uninstallHook(type)
        }
    }
    
    /// 更新所有已安装的Git hooks
    public func updateInstalledHooks() throws {
        for type in HookType.allCases {
            let hookPath = hooksDir + type.rawValue
            if hookPath.exists {
                try installHook(type)
            }
        }
    }
    
    /// 检查指定的Git hook是否已安装
    /// - Parameter type: hook类型
    /// - Returns: 是否已安装
    public func isHookInstalled(_ type: HookType) -> Bool {
        let hookPath = hooksDir + type.rawValue
        return hookPath.exists
    }
    
    /// 获取所有已安装的Git hooks
    /// - Returns: 已安装的hook类型数组
    public func getInstalledHooks() -> [HookType] {
        return HookType.allCases.filter { isHookInstalled($0) }
    }
    
    // MARK: - Private Methods
    
    private func installHook(_ type: HookType) throws {
        let hookPath = hooksDir + type.rawValue
        
        do {
            // 写入hook脚本
            try type.scriptContent.write(to: hookPath.url, atomically: true, encoding: .utf8)
            
            // 设置可执行权限
            try shellOut(to: "chmod", arguments: ["+x", hookPath.string])
        } catch {
            throw HookError.hookCreationFailed(type.rawValue)
        }
    }
    
    private func uninstallHook(_ type: HookType) throws {
        let hookPath = hooksDir + type.rawValue
        
        do {
            try hookPath.delete()
        } catch {
            throw HookError.hookDeletionFailed(type.rawValue)
        }
    }
} 