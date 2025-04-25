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
    throw new Error('未找到配置文件，请先运行 treeskit init');
  }
}

async function getDirectoryDescription(dir) {
  switch(dir.toLowerCase()) {
    case 'src':
    case 'sources':
      return '源代码目录';
    case 'tests':
      return '测试文件目录';
    case 'resources':
      return '资源文件目录';
    case 'docs':
      return '文档目录';
    case 'bin':
      return '可执行文件目录';
    case 'lib':
      return '库文件目录';
    case 'config':
      return '配置文件目录';
    case 'scripts':
      return '脚本文件目录';
    case 'assets':
      return '资源文件目录';
    case 'public':
      return '公共文件目录';
    case 'private':
      return '私有文件目录';
    case 'vendor':
      return '第三方依赖目录';
    case 'dist':
    case 'build':
      return '构建输出目录';
    default:
      return null;
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

    // 获取一级目录列表
    const rootDirs = execSync('ls -d */ 2>/dev/null || true', { encoding: 'utf8' })
      .trim()
      .split('\n')
      .filter(Boolean)
      .map(dir => dir.replace('/', ''));

    // 生成目录说明
    const directoryDescriptions = await Promise.all(
      rootDirs.map(async dir => {
        const desc = await getDirectoryDescription(dir);
        return desc ? `- \`${dir}/\`: ${desc}` : null;
      })
    );

    // 过滤掉没有描述的目录
    const validDescriptions = directoryDescriptions.filter(Boolean);

    // 生成markdown文档
    const markdown = `# ${config.projectName} 项目结构

## 目录结构

\`\`\`
${treeOutput}
\`\`\`

${validDescriptions.length > 0 ? `
## 主要目录说明

${validDescriptions.join('\n')}
` : ''}

> 本文档由 treeskit 自动生成
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