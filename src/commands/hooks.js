const chalk = require('chalk');
const fs = require('fs').promises;
const path = require('path');
const GitHooksManager = require('../utils/GitHooksManager');

async function loadConfig() {
  try {
    const configPath = path.join(process.cwd(), '.projectstructure.json');
    const configData = await fs.readFile(configPath, 'utf8');
    return JSON.parse(configData);
  } catch (error) {
    throw new Error('未找到配置文件，请先运行 treeskit init');
  }
}

async function saveConfig(config) {
  await fs.writeFile(
    path.join(process.cwd(), '.projectstructure.json'),
    JSON.stringify(config, null, 2)
  );
}

async function manageHooks(action) {
  try {
    const config = await loadConfig();
    const hooksManager = new GitHooksManager(process.cwd());

    switch (action) {
      case 'enable':
        if (config.useGitHooks) {
          console.log(chalk.yellow('Git Hooks已经处于启用状态'));
          return;
        }
        await hooksManager.installHook();
        config.useGitHooks = true;
        await saveConfig(config);
        console.log(chalk.green('✓ Git Hooks已启用'));
        break;

      case 'disable':
        if (!config.useGitHooks) {
          console.log(chalk.yellow('Git Hooks已经处于禁用状态'));
          return;
        }
        await hooksManager.uninstallHook();
        config.useGitHooks = false;
        await saveConfig(config);
        console.log(chalk.green('✓ Git Hooks已禁用'));
        break;

      case 'status':
        const isGitRepo = await hooksManager.isGitRepository();
        if (!isGitRepo) {
          console.log(chalk.yellow('当前目录不是git仓库'));
          return;
        }
        console.log('Git Hooks状态：', config.useGitHooks ? '已启用' : '已禁用');
        break;

      default:
        throw new Error('无效的操作');
    }
  } catch (error) {
    if (error.message === '无效的操作') {
      console.error(chalk.red(error.message));
      process.exit(1);
    } else {
      throw error;
    }
  }
}

module.exports = manageHooks; 