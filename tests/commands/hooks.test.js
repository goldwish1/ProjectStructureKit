const mockFs = require('mock-fs');
const fs = require('fs').promises;
const path = require('path');
const manageHooks = require('../../src/commands/hooks');

jest.mock('chalk', () => ({
  green: jest.fn(str => str),
  yellow: jest.fn(str => str),
  red: jest.fn(str => str),
  blue: jest.fn(str => str)
}));

describe('hooks command', () => {
  const testDir = process.cwd();
  const configPath = path.join(testDir, '.projectstructure.json');
  const gitDir = path.join(testDir, '.git');
  const hooksDir = path.join(gitDir, 'hooks');
  const preCommitPath = path.join(hooksDir, 'pre-commit');

  beforeEach(() => {
    // 重置console.log的mock
    jest.spyOn(console, 'log').mockImplementation(() => {});
    jest.spyOn(console, 'error').mockImplementation(() => {});
    
    // 模拟文件系统
    mockFs({
      [configPath]: JSON.stringify({
        projectName: 'test-project',
        useGitHooks: false,
        outputPath: 'docs',
        ignorePaths: []
      }),
      [gitDir]: {
        'hooks': {}
      },
      // 添加Jest所需的模块
      'node_modules/jest-message-util': {},
      'node_modules/jest-mock': {},
      'node_modules/jest-util': {}
    });
  });

  afterEach(() => {
    mockFs.restore();
    jest.clearAllMocks();
  });

  describe('enable', () => {
    it('应该成功启用hooks', async () => {
      await manageHooks('enable');
      
      // 验证配置文件更新
      const config = JSON.parse(await fs.readFile(configPath, 'utf8'));
      expect(config.useGitHooks).toBe(true);

      // 验证hook文件创建
      const hookExists = await fs.access(preCommitPath)
        .then(() => true)
        .catch(() => false);
      expect(hookExists).toBe(true);
    });

    it('hooks已启用时应该显示提示', async () => {
      // 先设置为已启用
      await fs.writeFile(configPath, JSON.stringify({
        projectName: 'test-project',
        useGitHooks: true,
        outputPath: 'docs',
        ignorePaths: []
      }));

      await manageHooks('enable');
      expect(console.log).toHaveBeenCalledWith(expect.stringContaining('已经处于启用状态'));
    });
  });

  describe('disable', () => {
    it('应该成功禁用hooks', async () => {
      // 先启用hooks
      await manageHooks('enable');
      await manageHooks('disable');

      // 验证配置文件更新
      const config = JSON.parse(await fs.readFile(configPath, 'utf8'));
      expect(config.useGitHooks).toBe(false);
    });

    it('hooks已禁用时应该显示提示', async () => {
      await manageHooks('disable');
      expect(console.log).toHaveBeenCalledWith(expect.stringContaining('已经处于禁用状态'));
    });
  });

  describe('status', () => {
    it('应该显示hooks启用状态', async () => {
      await manageHooks('status');
      expect(console.log).toHaveBeenCalledWith('Git Hooks状态：', '已禁用');

      // 启用后检查状态
      await manageHooks('enable');
      await manageHooks('status');
      expect(console.log).toHaveBeenCalledWith('Git Hooks状态：', '已启用');
    });

    it('在非git仓库中应该显示提示', async () => {
      mockFs.restore();
      mockFs({
        [configPath]: JSON.stringify({
          projectName: 'test-project',
          useGitHooks: false,
          outputPath: 'docs',
          ignorePaths: []
        }),
        // 添加Jest所需的模块
        'node_modules/jest-message-util': {},
        'node_modules/jest-mock': {},
        'node_modules/jest-util': {}
      });

      await manageHooks('status');
      expect(console.log).toHaveBeenCalledWith(expect.stringContaining('不是git仓库'));
    });
  });

  describe('error handling', () => {
    it('配置文件不存在时应该抛出错误', async () => {
      mockFs.restore();
      mockFs({
        [gitDir]: {
          'hooks': {}
        },
        // 添加Jest所需的模块
        'node_modules/jest-message-util': {},
        'node_modules/jest-mock': {},
        'node_modules/jest-util': {}
      });

      await expect(manageHooks('status')).rejects.toThrow(/未找到配置文件/);
    });

    it('无效的操作应该抛出错误', async () => {
      const processExitSpy = jest.spyOn(process, 'exit').mockImplementation(() => {});
      await manageHooks('invalid');
      expect(processExitSpy).toHaveBeenCalledWith(1);
    });
  });
}); 