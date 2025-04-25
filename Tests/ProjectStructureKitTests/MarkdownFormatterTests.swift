import XCTest
@testable import ProjectStructureKit

final class MarkdownFormatterTests: XCTestCase {
    private var formatter: MarkdownFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = MarkdownFormatter()
    }
    
    func testFormatBasicStructure() {
        // 创建测试结构
        let structure = ProjectStructureGenerator.FileNode(
            path: "/test/project",
            isDirectory: true,
            children: [
                .init(
                    path: "/test/project/file.swift",
                    isDirectory: false,
                    size: 1024,
                    lineCount: 100
                ),
                .init(
                    path: "/test/project/folder",
                    isDirectory: true,
                    children: [
                        .init(
                            path: "/test/project/folder/nested.swift",
                            isDirectory: false,
                            size: 512,
                            lineCount: 50
                        )
                    ]
                )
            ]
        )
        
        // 格式化
        let markdown = formatter.format(structure: structure)
        
        // 验证格式
        XCTAssertTrue(markdown.contains("# 项目结构"))
        XCTAssertTrue(markdown.contains("📄 file.swift"))
        XCTAssertTrue(markdown.contains("📁 folder"))
        XCTAssertTrue(markdown.contains("📄 nested.swift"))
        XCTAssertTrue(markdown.contains("(1.0 KB)"))
        XCTAssertTrue(markdown.contains("[100行]"))
        XCTAssertTrue(markdown.contains("(512.0 B)"))
        XCTAssertTrue(markdown.contains("[50行]"))
    }
    
    func testCustomOptions() {
        // 创建自定义选项
        let options = MarkdownFormatter.Options(
            indentSize: 4,
            showFileSize: false,
            showLineCount: false,
            includeHeader: false,
            headerLevel: 2
        )
        
        formatter = MarkdownFormatter(options: options)
        
        // 创建测试结构
        let structure = ProjectStructureGenerator.FileNode(
            path: "/test/project",
            isDirectory: true,
            children: [
                .init(
                    path: "/test/project/file.swift",
                    isDirectory: false,
                    size: 1024,
                    lineCount: 100
                )
            ]
        )
        
        // 格式化
        let markdown = formatter.format(structure: structure)
        
        // 验证格式
        XCTAssertFalse(markdown.contains("# 项目结构"))
        XCTAssertFalse(markdown.contains("1.0 KB"))
        XCTAssertFalse(markdown.contains("100行"))
        XCTAssertTrue(markdown.contains("    - 📄 file.swift"))
    }
    
    func testEmptyStructure() {
        // 创建空结构
        let structure = ProjectStructureGenerator.FileNode(
            path: "/test/project",
            isDirectory: true
        )
        
        // 格式化
        let markdown = formatter.format(structure: structure)
        
        // 验证格式
        XCTAssertTrue(markdown.contains("# 项目结构"))
        XCTAssertTrue(markdown.contains("📁 project"))
    }
    
    func testNestedStructure() {
        // 创建深层嵌套结构
        let structure = ProjectStructureGenerator.FileNode(
            path: "/test/project",
            isDirectory: true,
            children: [
                .init(
                    path: "/test/project/level1",
                    isDirectory: true,
                    children: [
                        .init(
                            path: "/test/project/level1/level2",
                            isDirectory: true,
                            children: [
                                .init(
                                    path: "/test/project/level1/level2/file.swift",
                                    isDirectory: false,
                                    size: 100,
                                    lineCount: 10
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        // 格式化
        let markdown = formatter.format(structure: structure)
        
        // 验证缩进
        let lines = markdown.components(separatedBy: .newlines)
        XCTAssertTrue(lines.contains { $0.contains("  - 📁 level1") })
        XCTAssertTrue(lines.contains { $0.contains("    - 📁 level2") })
        XCTAssertTrue(lines.contains { $0.contains("      - 📄 file.swift") })
    }
} 