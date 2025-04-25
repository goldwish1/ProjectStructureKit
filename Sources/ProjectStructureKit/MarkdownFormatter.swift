import Foundation

/// Markdown格式化器
public class MarkdownFormatter {
    /// 格式化选项
    public struct Options {
        public let indentSize: Int
        public let showFileSize: Bool
        public let showLineCount: Bool
        public let includeHeader: Bool
        public let headerLevel: Int
        
        public static let `default` = Options(
            indentSize: 2,
            showFileSize: true,
            showLineCount: true,
            includeHeader: true,
            headerLevel: 1
        )
        
        public init(
            indentSize: Int = 2,
            showFileSize: Bool = true,
            showLineCount: Bool = true,
            includeHeader: Bool = true,
            headerLevel: Int = 1
        ) {
            self.indentSize = indentSize
            self.showFileSize = showFileSize
            self.showLineCount = showLineCount
            self.includeHeader = includeHeader
            self.headerLevel = headerLevel
        }
    }
    
    private let options: Options
    
    public init(options: Options = .default) {
        self.options = options
    }
    
    /// 将项目结构转换为Markdown格式
    public func format(structure: ProjectStructureGenerator.FileNode) -> String {
        var output = ""
        
        if options.includeHeader {
            output += String(repeating: "#", count: options.headerLevel)
            output += " 项目结构\n\n"
        }
        
        output += formatNode(structure, level: 0)
        return output
    }
    
    private func formatNode(_ node: ProjectStructureGenerator.FileNode, level: Int) -> String {
        let indent = String(repeating: " ", count: level * options.indentSize)
        var output = indent + "- "
        
        // 添加文件/目录名
        let name = (node.path as NSString).lastPathComponent
        output += node.isDirectory ? "📁 \(name)" : "📄 \(name)"
        
        // 添加文件大小
        if options.showFileSize, let size = node.size {
            output += " (\(formatFileSize(size)))"
        }
        
        // 添加行数
        if options.showLineCount, let lines = node.lineCount {
            output += " [\(lines)行]"
        }
        
        output += "\n"
        
        // 处理子节点
        if let children = node.children {
            for child in children {
                output += formatNode(child, level: level + 1)
            }
        }
        
        return output
    }
    
    private func formatFileSize(_ size: UInt64) -> String {
        let units = ["B", "KB", "MB", "GB"]
        var size = Double(size)
        var unitIndex = 0
        
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        
        return String(format: "%.1f %@", size, units[unitIndex])
    }
} 