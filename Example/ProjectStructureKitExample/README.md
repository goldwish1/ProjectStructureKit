# ProjectStructureKit 示例项目

这个示例项目展示了如何在iOS项目中使用ProjectStructureKit来自动生成和维护项目结构文档。

## 功能展示

本示例展示了以下功能：
1. 配置ProjectStructureKit
2. 设置Git Hooks
3. 生成项目结构文档
4. 检查文档状态

## 如何运行

1. 克隆仓库
```bash
git clone <repository-url>
cd ProjectStructureKitExample
```

2. 构建和运行
```bash
swift build
swift run
```

## 示例输出

运行示例程序后，你将看到以下输出：
- Git hooks设置成功的确认
- 文档生成成功的确认
- 当前文档状态的报告

## 项目结构

```
ProjectStructureKitExample/
├── Package.swift           # 包配置文件
├── README.md              # 本文档
├── Sources/               # 源代码目录
│   └── main.swift         # 主程序
└── Documentation/         # 生成的文档目录
    └── ARCHITECTURE.md    # 自动生成的项目结构文档
```

## 注意事项

- 确保已安装tree命令行工具
- 确保项目目录是一个Git仓库
- 查看生成的ARCHITECTURE.md文件以了解自动生成的文档效果 