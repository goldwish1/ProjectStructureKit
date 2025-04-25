const mockFs = require('mock-fs');
const fs = require('fs').promises;
const path = require('path');
const GitHooksManager = require('../../src/utils/GitHooksManager');

describe('GitHooksManager', () => {
  let manager;
  const testDir = '/test/project';
  const gitDir = path.join(testDir, '.git');
  const hooksDir = path.join(gitDir, 'hooks');
  const preCommitPath = path.join(hooksDir, 'pre-commit');

  beforeEach(() => {
    manager = new GitHooksManager(testDir);
    // 模拟文件系统
    mockFs({
      [gitDir]: {
        'hooks': {
          'pre-commit': '#!/bin/sh\necho "Original hook"'
        }
      }
    });
  });

  afterEach(() => {
    mockFs.restore();
  });

  describe('isGitRepository', () => {
    it('应该在.git目录存在时返回true', async () => {
      expect(await manager.isGitRepository()).toBe(true);
    });

    it('应该在.git目录不存在时返回false', async () => {
      mockFs.restore();
      mockFs({
        [testDir]: {} // 空目录
      });
      expect(await manager.isGitRepository()).toBe(false);
    });
  });

  describe('backupHook', () => {
    it('应该成功备份现有的hook', async () => {
      const result = await manager.backupHook();
      expect(result).toBe(true);
      
      const backupExists = await fs.access(`${preCommitPath}.backup`)
        .then(() => true)
        .catch(() => false);
      expect(backupExists).toBe(true);
    });

    it('在没有现有hook时应该返回false', async () => {
      mockFs.restore();
      mockFs({
        [gitDir]: {
          'hooks': {}
        }
      });
      const result = await manager.backupHook();
      expect(result).toBe(false);
    });
  });

  describe('restoreHook', () => {
    it('应该成功恢复备份的hook', async () => {
      await manager.backupHook();
      const result = await manager.restoreHook();
      expect(result).toBe(true);

      const hookContent = await fs.readFile(preCommitPath, 'utf8');
      expect(hookContent).toContain('Original hook');
    });

    it('在没有备份时应该返回false', async () => {
      const result = await manager.restoreHook();
      expect(result).toBe(false);
    });
  });

  describe('installHook', () => {
    it('应该成功安装新的hook', async () => {
      await manager.installHook();
      const hookContent = await fs.readFile(preCommitPath, 'utf8');
      expect(hookContent).toContain('npx treeskit generate');
    });

    it('在非git仓库中应该抛出错误', async () => {
      mockFs.restore();
      mockFs({
        [testDir]: {} // 空目录
      });
      await expect(manager.installHook()).rejects.toThrow('当前目录不是git仓库');
    });

    it('应该备份现有的hook', async () => {
      await manager.installHook();
      const backupExists = await fs.access(`${preCommitPath}.backup`)
        .then(() => true)
        .catch(() => false);
      expect(backupExists).toBe(true);
    });
  });

  describe('uninstallHook', () => {
    it('应该成功卸载hook并恢复备份', async () => {
      await manager.installHook();
      await manager.uninstallHook();
      const hookContent = await fs.readFile(preCommitPath, 'utf8');
      expect(hookContent).toContain('Original hook');
    });

    it('在没有备份时应该删除hook', async () => {
      mockFs.restore();
      mockFs({
        [gitDir]: {
          'hooks': {
            'pre-commit': '#!/bin/sh\nnpx treeskit generate'
          }
        }
      });
      await manager.uninstallHook();
      const hookExists = await fs.access(preCommitPath)
        .then(() => true)
        .catch(() => false);
      expect(hookExists).toBe(false);
    });
  });
}); 