import XCTest
import PathKit
@testable import ProjectStructureKit

final class ProjectStructureGeneratorTests: XCTestCase {
    private var tempDirectory: Path!
    private var generator: ProjectStructureGenerator!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // 创建临时目录
        tempDirectory = Path.temporary + "ProjectStructureKitTests"
        try? tempDirectory.delete()
        try tempDirectory.mkdir()
        
        // 创建测试文件结构
        try createTestFileStructure()
        
        // 初始化生成器
        generator = ProjectStructureGenerator(
            rootPath: tempDirectory.string,
            ignoredPaths: [],
            maxDepth: nil,
            includeFileSize: true,
            includeLineCount: true
        )
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        try? tempDirectory.delete()
    }
    
    func testGenerateStructure() throws {
        // 生成结构
        let structure = try generator.generateStructure()
        
        // 验证根目录
        XCTAssertEqual(structure.path, tempDirectory.string)
        XCTAssertTrue(structure.isDirectory)
        XCTAssertNotNil(structure.children)
        
        // 验证子目录和文件
        let children = structure.children!
        XCTAssertEqual(children.count, 3) // src, tests, docs
        
        // 验证src目录
        let src = children.first { $0.path.hasSuffix("src") }
        XCTAssertNotNil(src)
        XCTAssertTrue(src!.isDirectory)
        XCTAssertEqual(src!.children?.count, 2)
        
        // 验证文件属性
        let file = src!.children!.first { !$0.isDirectory }
        XCTAssertNotNil(file)
        XCTAssertFalse(file!.isDirectory)
        XCTAssertNotNil(file!.size)
        XCTAssertNotNil(file!.lineCount)
    }
    
    func testIgnoredPaths() throws {
        // 使用忽略路径创建新生成器
        generator = ProjectStructureGenerator(
            rootPath: tempDirectory.string,
            ignoredPaths: ["tests", "*.md"],
            maxDepth: nil,
            includeFileSize: true,
            includeLineCount: true
        )
        
        // 生成结构
        let structure = try generator.generateStructure()
        
        // 验证忽略的路径
        let children = structure.children!
        XCTAssertFalse(children.contains { $0.path.hasSuffix("tests") })
        XCTAssertFalse(children.contains { $0.path.hasSuffix(".md") })
    }
    
    func testMaxDepth() throws {
        // 使用最大深度创建新生成器
        generator = ProjectStructureGenerator(
            rootPath: tempDirectory.string,
            ignoredPaths: [],
            maxDepth: 1,
            includeFileSize: true,
            includeLineCount: true
        )
        
        // 生成结构
        let structure = try generator.generateStructure()
        
        // 验证最大深度
        XCTAssertNotNil(structure.children)
        for child in structure.children! {
            if child.isDirectory {
                XCTAssertNil(child.children)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestFileStructure() throws {
        // 创建src目录
        let src = tempDirectory + "src"
        try src.mkdir()
        
        // 创建源文件
        let sourceFile = src + "main.swift"
        try "func main() {\n    print(\"Hello, World!\")\n}\n".write(to: sourceFile.url, atomically: true, encoding: .utf8)
        
        let utilsFile = src + "utils.swift"
        try "struct Utils {}\n".write(to: utilsFile.url, atomically: true, encoding: .utf8)
        
        // 创建tests目录
        let tests = tempDirectory + "tests"
        try tests.mkdir()
        try "import XCTest\n".write(to: (tests + "test.swift").url, atomically: true, encoding: .utf8)
        
        // 创建docs目录
        let docs = tempDirectory + "docs"
        try docs.mkdir()
        try "# Documentation\n".write(to: (docs + "README.md").url, atomically: true, encoding: .utf8)
    }
} 