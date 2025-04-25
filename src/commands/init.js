const chalk = require('chalk');
const inquirer = require('inquirer');
const fs = require('fs').promises;
const path = require('path');
const { execSync } = require('child_process');

async function initializeProject() {
  try {
    // 检查是否在iOS项目目录中
    const questions = [
      {
        type: 'input',
        name: 'projectName',
        message: '请输入项目名称:',
        validate: input => input.trim().length > 0
      },
      {
        type: 'confirm',
        name: 'useGitHooks',
        message: '是否启用Git Hooks来自动更新文档?',
        default: true
      }
    ];

    const answers = await inquirer.prompt(questions);

    // 创建配置文件
    const config = {
      projectName: answers.projectName,
      useGitHooks: answers.useGitHooks,
      outputPath: 'docs',
      ignorePaths: [
        'node_modules',
        '.git',
        'build',
        'DerivedData'
      ]
    };

    // 保存配置文件
    await fs.writeFile(
      path.join(process.cwd(), '.projectstructure.json'),
      JSON.stringify(config, null, 2)
    );

    console.log(chalk.green('✓ 配置文件已创建'));

    if (answers.useGitHooks) {
      try {
        // 安装 husky
        console.log(chalk.blue('正在安装 husky...'));
        execSync('npm install husky --save-dev', { stdio: 'inherit' });
        
        // 初始化 husky
        console.log(chalk.blue('正在初始化 husky...'));
        execSync('npx husky init', { stdio: 'inherit' });
        
        // 创建 pre-commit hook 文件
        console.log(chalk.blue('正在配置 pre-commit hook...'));
        // 添加 update-docs 脚本到 package.json
        execSync('npm pkg set scripts.update-docs="project-structure generate"', { stdio: 'inherit' });
        
        // 创建 pre-commit hook 文件
        const hookPath = path.join(process.cwd(), '.husky', 'pre-commit');
        const hookContent = `#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npm run update-docs
git add docs/PROJECT_STRUCTURE.md`;
        
        await fs.writeFile(hookPath, hookContent, { mode: 0o755 });
        
        console.log(chalk.green('✓ Git Hooks已配置'));
      } catch (error) {
        console.error(chalk.yellow('警告: Git Hooks配置失败，请手动配置'), error.message);
      }
    }

    console.log(chalk.blue('\n初始化完成！现在您可以使用以下命令：'));
    console.log(chalk.yellow('\n  project-structure generate') + ' - 生成项目结构文档');
    console.log(chalk.yellow('  project-structure config') + ' - 修改配置\n');

  } catch (error) {
    console.error(chalk.red('初始化失败：'), error.message);
    process.exit(1);
  }
}

module.exports = initializeProject; 