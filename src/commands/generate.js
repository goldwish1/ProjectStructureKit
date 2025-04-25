const chalk = require('chalk');
const fs = require('fs').promises;
const path = require('path');
const { execSync } = require('child_process');

async function loadConfig() {
  try {
    const configPath = path.join(process.cwd(), '.projectstructure.json');
    const configData = await fs.readFile(configPath, 'utf8');
    return JSON.parse(configData);
  } catch (error) {
    throw new Error('未找到配置文件，请先运行 project-structure init');
  }
}

async function generateDocumentation(options) {
  try {
    const config = await loadConfig();
    const outputPath = options.output || config.outputPath;

    console.log(chalk.blue('正在生成项目结构文档...'));

    // 确保输出目录存在
    await fs.mkdir(outputPath, { recursive: true });

    // 使用tree命令生成目录结构
    const treeOutput = execSync('tree -L 3 -I "node_modules|.git|build|DerivedData"', {
      encoding: 'utf8'
    });

    // 生成markdown文档
    const markdown = `# ${config.projectName} 项目结构

## 目录结构

\`\`\`
${treeOutput}
\`\`\`

## 主要目录说明

- \`Sources/\`: 源代码目录
- \`Tests/\`: 测试文件目录
- \`Resources/\`: 资源文件目录
- \`docs/\`: 文档目录

> 本文档由 ProjectStructureKit 自动生成
`;

    // 保存文档
    const docPath = path.join(outputPath, 'PROJECT_STRUCTURE.md');
    await fs.writeFile(docPath, markdown);

    console.log(chalk.green(`✓ 文档已生成：${docPath}`));

  } catch (error) {
    console.error(chalk.red('生成文档失败：'), error.message);
    process.exit(1);
  }
}

module.exports = generateDocumentation; 