#!/usr/bin/env node

const { program } = require('commander');
const chalk = require('chalk');
const pkg = require('../package.json');

// 导入命令实现
const initializeProject = require('../src/commands/init');
const generateDocumentation = require('../src/commands/generate');
const configureProject = require('../src/commands/config');

// 设置版本号和描述
program
  .version(pkg.version)
  .description('ProjectStructureKit CLI - iOS项目结构文档生成工具');

// 初始化命令
program
  .command('init')
  .description('在iOS项目中初始化ProjectStructureKit')
  .action(initializeProject);

// 生成文档命令
program
  .command('generate')
  .description('生成项目结构文档')
  .option('-o, --output <path>', '文档输出路径')
  .action(generateDocumentation);

// 配置命令
program
  .command('config')
  .description('配置ProjectStructureKit设置')
  .action(configureProject);

// 解析命令行参数
program.parse(process.argv); 