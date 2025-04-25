# ProjectStructureKit CLI 使用指南

ProjectStructureKit CLI 是一个命令行工具，用于帮助iOS开发者自动生成和维护项目结构文档。

## 安装

```bash
# 使用npm全局安装
npm install -g project-structure-kit-cli

# 或者使用npx直接运行（无需安装）
npx project-structure-kit-cli <命令>
```

## 命令说明

### 初始化项目

```bash
project-structure init
```

此命令用于在iOS项目中初始化ProjectStructureKit。它会：
- 创建配置文件 `.projectstructure.json`
- 设置基本的项目配置
- 可选择性地配置Git Hooks

交互式配置过程会询问：
- 项目名称
- 是否启用Git Hooks自动更新文档

### 生成文档

```bash
project-structure generate [选项]
```

生成项目结构文档。

选项：
- `-o, --output <path>` - 指定文档输出路径（默认：docs）

生成的文档包含：
- 项目目录结构树形图
- 主要目录说明
- 自动更新时间戳

### 配置管理

```bash
project-structure config
```

交互式配置ProjectStructureKit的设置，包括：
- 修改项目名称
- 更改文档输出路径
- 启用/禁用Git Hooks
- 设置忽略的文件/目录

## 配置文件说明

`.projectstructure.json` 配置文件结构：

```json
{
  "projectName": "项目名称",
  "useGitHooks": true,
  "outputPath": "docs",
  "ignorePaths": [
    "node_modules",
    ".git",
    "build",
    "DerivedData"
  ]
}
```

## 使用示例

### 基本使用流程

1. 初始化项目：
```bash
cd your-ios-project
project-structure init
```

2. 生成文档：
```bash
project-structure generate
```

3. 修改配置：
```bash
project-structure config
```

### Git Hooks自动更新

如果启用了Git Hooks，文档会在以下情况自动更新：
- 执行 `git commit` 时
- 执行 `git push` 时

### 自定义输出路径

```bash
# 生成文档到指定路径
project-structure generate -o ./documentation

# 或者通过config命令修改默认输出路径
project-structure config
```

## 常见问题

1. **找不到tree命令**
   ```bash
   # macOS安装tree
   brew install tree
   
   # Linux安装tree
   sudo apt-get install tree  # Ubuntu/Debian
   sudo yum install tree      # CentOS/RHEL
   ```

2. **配置文件不存在**
   - 确保先运行 `project-structure init`
   - 检查是否在正确的项目目录中

3. **Git Hooks不生效**
   - 确保项目是Git仓库
   - 检查 `.git/hooks` 目录权限
   - 重新运行 `project-structure init`

## 最佳实践

1. **定期更新文档**
   - 推荐启用Git Hooks自动更新
   - 在重要更改后手动运行generate命令

2. **配置忽略路径**
   - 添加临时文件目录
   - 添加构建产物目录
   - 添加依赖目录

3. **文档位置**
   - 建议将文档放在专门的文档目录
   - 确保文档目录被版本控制追踪

## 更新日志

### v1.0.0
- 初始版本发布
- 支持基本的文档生成功能
- 支持Git Hooks自动更新
- 提供完整的配置管理 