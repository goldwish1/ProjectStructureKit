#!/usr/bin/env node

const { program } = require('commander');
const chalk = require('chalk');
const init = require('../src/commands/init');
const generate = require('../src/commands/generate');
const config = require('../src/commands/config');

// 版本号从package.json中读取
const { version } = require('../package.json');

// 设置版本号
program.version(version);

// 设置CLI描述
program
  .description('treeskit - iOS项目结构文档生成工具');

// init命令
program
  .command('init')
  .description('初始化项目配置')
  .action(init);

// generate命令
program
  .command('generate')
  .description('生成项目结构文档')
  .option('-o, --output <path>', '指定输出路径')
  .action(generate);

// config命令
program
  .command('config')
  .description('管理工具配置')
  .action(config);

// 解析命令行参数
program.parse(process.argv); 