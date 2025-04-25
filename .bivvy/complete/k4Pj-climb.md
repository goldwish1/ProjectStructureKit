<Climb>
  <header>
    <id>k4Pj</id>
    <type>feature</type>
    <description>优化Git Hooks实现方式，减少对用户环境的污染</description>
  </header>
  <newDependencies>
    无需新增依赖，反而会移除husky依赖
  </newDependencies>
  <prerequisitChanges>
    - 需要移除现有的husky相关配置
    - 需要调整项目初始化流程
  </prerequisitChanges>
  <relevantFiles>
    - package.json（移除husky依赖）
    - src/init.js 或类似的初始化文件
    - .husky/目录（需要移除）
  </relevantFiles>

功能概述：
- 功能名称：原生Git Hooks实现文档自动更新
- 目的：通过使用git原生hooks机制来实现文档自动更新，减少对用户项目环境的污染
- 解决问题：当前使用husky会在用户项目中创建额外的文件和配置，造成不必要的环境污染
- 成功指标：
  1. 成功移除husky依赖
  2. 文档自动更新功能正常工作
  3. 用户项目中不会出现额外的配置文件和目录

需求：

功能需求：
1. 在用户执行`npx treeskit init`时，提供选项是否启用git hooks
2. 如果用户选择启用，自动在.git/hooks目录创建pre-commit钩子
3. 保持文档自动更新功能的所有现有功能
4. 提供启用/禁用hooks的命令行选项

技术需求：
1. pre-commit钩子脚本需要具备可执行权限
2. 钩子脚本需要处理各种异常情况
3. 确保在非git仓库中优雅降级
4. 备份用户现有的pre-commit钩子（如果存在）

用户需求：
1. 安装过程对用户透明
2. 提供清晰的提示信息
3. 允许用户随时启用/禁用功能
4. 提供卸载时的清理功能

实现细节：

钩子脚本内容：
```bash
#!/bin/sh
if command -v npx >/dev/null 2>&1; then
  npx treeskit generate
  git add docs/
else
  echo "Warning: npx not found, skipping document generation"
  exit 0
fi
```

安全考虑：
1. 备份现有hooks
2. 确保脚本权限正确
3. 不修改用户其他git配置

测试方案：
1. 测试hooks安装/卸载流程
2. 测试文档自动更新功能
3. 测试异常处理
4. 测试在不同环境下的行为

未来考虑：
1. 支持自定义hooks触发时机
2. 支持更多的git hooks类型
3. 提供hooks模板系统
</Climb> 