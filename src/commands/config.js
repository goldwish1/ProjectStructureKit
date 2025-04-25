const chalk = require('chalk');
const inquirer = require('inquirer');
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

async function configureProject() {
  try {
    const config = await loadConfig();
    const hooksManager = new GitHooksManager(process.cwd());

    const questions = [
      {
        type: 'input',
        name: 'projectName',
        message: '项目名称:',
        default: config.projectName
      },
      {
        type: 'input',
        name: 'outputPath',
        message: '文档输出路径:',
        default: config.outputPath
      },
      {
        type: 'confirm',
        name: 'useGitHooks',
        message: '是否启用Git Hooks:',
        default: config.useGitHooks
      },
      {
        type: 'input',
        name: 'ignorePaths',
        message: '忽略的路径（用逗号分隔）:',
        default: config.ignorePaths.join(','),
        filter: input => input.split(',').map(p => p.trim())
      }
    ];

    const answers = await inquirer.prompt(questions);

    // 处理Git Hooks的变更
    if (answers.useGitHooks !== config.useGitHooks) {
      try {
        if (answers.useGitHooks) {
          await hooksManager.installHook();
          console.log(chalk.green('✓ Git Hooks已启用'));
        } else {
          await hooksManager.uninstallHook();
          console.log(chalk.green('✓ Git Hooks已禁用'));
        }
      } catch (error) {
        console.error(chalk.yellow('警告: Git Hooks操作失败，但配置已更新'), error.message);
      }
    }

    // 更新配置文件
    const newConfig = {
      ...config,
      ...answers
    };

    await fs.writeFile(
      path.join(process.cwd(), '.projectstructure.json'),
      JSON.stringify(newConfig, null, 2)
    );

    console.log(chalk.green('✓ 配置已更新'));

  } catch (error) {
    console.error(chalk.red('配置更新失败：'), error.message);
    process.exit(1);
  }
}

module.exports = configureProject; 