# ProjectStructureKit CLI 精简任务

<Climb>
  <header>
    <id>mdc</id>
    <type>task</type>
    <description>精简ProjectStructureKit，仅保留CLI工具使用方式</description>
  </header>
  <newDependencies>无需新增依赖</newDependencies>
  <prerequisitChanges>
    - 需要移除Swift Package相关的代码和配置
    - 需要移除CocoaPods相关的配置
    - 需要更新文档，移除SDK相关内容
  </prerequisitChanges>
  <relevantFiles>
    - README.md
    - Package.swift
    - Package.resolved
    - Sources/
    - Tests/
    - Example/
  </relevantFiles>

## 任务概述

### 目的
将ProjectStructureKit简化为纯CLI工具，移除所有SDK相关功能，使项目更加专注和轻量化。

### 当前状态
目前项目同时支持：
1. Swift Package SDK方式
2. CocoaPods集成方式
3. CLI工具使用方式（npx方式）

### 目标状态
项目将只保留：
- CLI工具使用方式（通过npx方式运行）
- 相关的命令行功能和文档

## 具体要求

### 需要移除的内容
1. Swift Package相关：
   - Package.swift文件
   - Package.resolved文件
   - Sources目录（如果仅用于SDK）
   - Tests目录（如果仅包含SDK测试）
   - Example目录（如果是SDK示例）

2. CocoaPods相关：
   - 移除README中的CocoaPods安装说明
   - 移除相关配置文件（如果有）

3. SDK相关文档：
   - 移除README中的SDK使用说明
   - 移除SDK配置说明
   - 移除Swift代码示例

### 需要保留的内容
1. CLI工具核心功能：
   - npx命令使用方式
   - 所有CLI相关的代码和功能
   - CLI配置文件格式说明
   - 命令行使用示例

2. 项目基础文件：
   - package.json（用于npm发布）
   - LICENSE
   - .gitignore
   - 必要的工具配置文件

### 文档更新
README.md需要重写，主要包含：
1. 项目简介（仅关注CLI工具功能）
2. CLI工具使用说明
3. 配置文件说明
4. 常见问题解答
5. 许可证信息

## 验收标准
1. 项目成功移除所有SDK相关代码和配置
2. CLI工具功能保持完整且正常工作
3. 文档更新完成，仅包含CLI工具相关内容
4. npm包可以正常发布和使用
5. 通过npx方式可以正常运行所有命令

## 注意事项
1. 确保移除SDK相关内容不会影响CLI工具的正常功能
2. 保持git提交历史完整
3. 更新版本号以反映重大变更
</Climb> 