import { Hook } from '@oclif/core';
import { writeFileSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { getPostDeployHooks } from '../utils/config-loader.js';
import { executeHooks } from '../utils/executor.js';

/**
 * Post-run hook that executes bash scripts after deploy commands.
 * 
 * This hook runs after deploy-related commands complete and executes post-deploy hooks
 * configured in .sfhooks.json or sf-hooks.json
 */
const hook: Hook.Postrun = async function (options) {
  const commandId = options.Command?.id;
  
  if (!commandId) {
    return;
  }

  // List of deploy-related commands that should trigger the post-deploy hooks
  const deployCommands = [
    'project:deploy:start',
    'project:deploy:validate',
    'project:deploy:quick',
    'project:deploy:resume',
  ];

  // Check if the current command is a deploy command
  const isDeployCommand = deployCommands.some(cmd => 
    commandId === cmd || commandId.startsWith('project:deploy')
  );

  if (!isDeployCommand) {
    return;
  }

  const cwd = process.cwd();
  const hooks = getPostDeployHooks(cwd);

  if (hooks.length === 0) {
    this.debug?.('No post-deploy hooks configured, skipping...');
    return;
  }

  // Capture deploy result and write to temp file for hook analysis
  let resultFilePath: string | undefined;
  if (options.result !== undefined) {
    try {
      const tmpDir = join(tmpdir(), 'sf-deploy-hooks');
      mkdirSync(tmpDir, { recursive: true });
      
      resultFilePath = join(tmpDir, `deploy-result-${Date.now()}.json`);
      const resultData = {
        command: commandId,
        argv: options.argv,
        timestamp: new Date().toISOString(),
        result: options.result,
      };
      
      writeFileSync(resultFilePath, JSON.stringify(resultData, null, 2), 'utf-8');
      this.debug?.(`Deploy result written to: ${resultFilePath}`);
    } catch (error) {
      this.warn?.(`Failed to write deploy result file: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  this.log?.(`🔧 Running ${hooks.length} post-deploy hook(s)...`);

  try {
    executeHooks(hooks, commandId, cwd, resultFilePath, { log: this.log, debug: this.debug });
    this.log?.('✅ Post-deploy hooks completed successfully');
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    // Don't throw - just log the error for post-deploy hooks
    this.warn?.(`⚠️  Post-deploy hook failed: ${message}`);
  }
};

export default hook;
