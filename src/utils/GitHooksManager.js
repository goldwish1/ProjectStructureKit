const fs = require('fs').promises;
const path = require('path');
const chalk = require('chalk');

class GitHooksManager {
  constructor(projectPath) {
    this.projectPath = projectPath;
    this.gitDir = path.join(projectPath, '.git');
    this.hooksDir = path.join(this.gitDir, 'hooks');
    this.preCommitPath = path.join(this.hooksDir, 'pre-commit');
  }

  async getGitConfig(key) {
    try {
      const { stdout } = await require('child_process').promisify(require('child_process').exec)(`git config --get ${key}`, {
        cwd: this.projectPath
      });
      return stdout.trim();
    } catch (error) {
      return null;
    }
  }

  async isGitRepository() {
    try {
      await fs.access(this.gitDir);
      return true;
    } catch {
      return false;
    }
  }

  async backupHook() {
    try {
      const exists = await fs.access(this.preCommitPath)
        .then(() => true)
        .catch(() => false);

      if (exists) {
        await fs.rename(this.preCommitPath, `${this.preCommitPath}.backup`);
        return true;
      }
      return false;
    } catch (error) {
      throw new Error(`备份hook失败: ${error.message}`);
    }
  }

  async restoreHook() {
    try {
      const backupExists = await fs.access(`${this.preCommitPath}.backup`)
        .then(() => true)
        .catch(() => false);

      if (backupExists) {
        await fs.rename(`${this.preCommitPath}.backup`, this.preCommitPath);
        return true;
      }
      return false;
    } catch (error) {
      throw new Error(`恢复hook失败: ${error.message}`);
    }
  }

  async installHook() {
    if (!await this.isGitRepository()) {
      throw new Error('当前目录不是git仓库，请先初始化git');
    }

    try {
      // 检查是否被其他工具接管
      const currentHooksPath = await this.getGitConfig('core.hooksPath');
      if (currentHooksPath) {
        throw new Error(`检测到其他 Git Hooks 管理工具（core.hooksPath=${currentHooksPath}），请先执行：git config --unset core.hooksPath`);
      }

      // 备份现有hook
      await this.backupHook();

      // 创建新的pre-commit hook，更健壮的版本
      const hookContent = `#!/bin/sh
set -e

# 查找配置文件
CONFIG_FILE=".projectstructure.json"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Warning: 配置文件 .projectstructure.json 不存在，跳过文档生成"
  exit 0
fi

# 获取输出目录
OUTPUT_DIR="docs"
if command -v node >/dev/null 2>&1; then
  # 使用node提取outputPath
  CUSTOM_OUTPUT_DIR=$(node -e "try { const config = require('./$CONFIG_FILE'); console.log(config.outputPath || 'docs'); } catch(e) { console.log('docs'); }")
  if [ -n "$CUSTOM_OUTPUT_DIR" ]; then
    OUTPUT_DIR="$CUSTOM_OUTPUT_DIR"
  fi
fi

# 尝试不同的方式运行
if command -v treeskit >/dev/null 2>&1; then
  echo "运行: treeskit generate"
  treeskit generate
elif command -v npx >/dev/null 2>&1; then
  echo "运行: npx treeskit generate"
  npx treeskit generate
else
  echo "Warning: 找不到treeskit命令，跳过文档生成"
  exit 0
fi

# 检查文档目录是否存在并添加到提交
if [ -d "$OUTPUT_DIR" ]; then
  echo "添加更新的文档到提交: $OUTPUT_DIR/"
  git add "$OUTPUT_DIR/"
fi

exit 0
`;

      // 确保hooks目录存在
      await fs.mkdir(this.hooksDir, { recursive: true });
      
      // 写入钩子脚本，并给予执行权限
      await fs.writeFile(this.preCommitPath, hookContent, { mode: 0o755 });
      
      // 双重确认权限设置
      await fs.chmod(this.preCommitPath, 0o755);
      
      return true;
    } catch (error) {
      throw new Error(`安装hook失败: ${error.message}`);
    }
  }

  async uninstallHook() {
    try {
      // 尝试恢复备份
      const restored = await this.restoreHook();
      
      if (!restored) {
        // 如果没有备份，直接删除当前hook
        await fs.unlink(this.preCommitPath).catch(() => {});
      }
      
      return true;
    } catch (error) {
      throw new Error(`卸载hook失败: ${error.message}`);
    }
  }
}

module.exports = GitHooksManager; 