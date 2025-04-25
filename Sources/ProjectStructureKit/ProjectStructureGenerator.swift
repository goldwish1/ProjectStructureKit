import Foundation
import PathKit
import ShellOut

/// 项目结构生成器
public class ProjectStructureGenerator {
    /// 文件节点结构
    public struct FileNode {
        public let path: String
        public let isDirectory: Bool
        public let size: UInt64?
        public let lineCount: UInt?
        public var children: [FileNode]?
        
        public init(
            path: String,
            isDirectory: Bool,
            size: UInt64? = nil,
            lineCount: UInt? = nil,
            children: [FileNode]? = nil
        ) {
            self.path = path
            self.isDirectory = isDirectory
            self.size = size
            self.lineCount = lineCount
            self.children = children
        }
    }
    
    private let rootPath: Path
    private let ignoredPaths: [String]
    private let maxDepth: Int?
    private let includeFileSize: Bool
    private let includeLineCount: Bool
    
    public init(
        rootPath: String,
        ignoredPaths: [String] = [],
        maxDepth: Int? = nil,
        includeFileSize: Bool = true,
        includeLineCount: Bool = true
    ) {
        self.rootPath = Path(rootPath)
        self.ignoredPaths = ignoredPaths
        self.maxDepth = maxDepth
        self.includeFileSize = includeFileSize
        self.includeLineCount = includeLineCount
    }
    
    /// 生成项目结构树
    public func generateStructure() throws -> FileNode {
        return try generateNode(path: rootPath, depth: 0)
    }
    
    private func generateNode(path: Path, depth: Int) throws -> FileNode {
        // 检查是否超过或等于最大深度
        if let maxDepth = maxDepth, depth >= maxDepth {
            return FileNode(path: path.string, isDirectory: true)
        }
        
        // 检查是否应该忽略
        if shouldIgnore(path: path) {
            return FileNode(path: path.string, isDirectory: true)
        }
        
        let isDirectory = path.isDirectory
        var size: UInt64? = nil
        var lineCount: UInt? = nil
        var children: [FileNode]? = nil
        
        if isDirectory {
            // 处理目录
            children = try path.children()
                .sorted { $0.string < $1.string }
                .compactMap { childPath -> FileNode? in
                    if shouldIgnore(path: childPath) { return nil }
                    return try? generateNode(path: childPath, depth: depth + 1)
                }
        } else {
            // 处理文件
            if includeFileSize {
                let attributes = try FileManager.default.attributesOfItem(atPath: path.string)
                size = attributes[.size] as? UInt64
            }
            if includeLineCount {
                lineCount = try countLines(in: path)
            }
        }
        
        return FileNode(
            path: path.string,
            isDirectory: isDirectory,
            size: size,
            lineCount: lineCount,
            children: children
        )
    }
    
    private func shouldIgnore(path: Path) -> Bool {
        let pathString = path.string
        return ignoredPaths.contains { pattern in
            if pattern.hasSuffix("*") {
                let prefix = String(pattern.dropLast())
                return pathString.hasPrefix(prefix)
            }
            return pathString.contains(pattern)
        }
    }
    
    private func countLines(in file: Path) throws -> UInt {
        let content = try String(contentsOf: file.url)
        return UInt(content.components(separatedBy: .newlines).count)
    }
} 