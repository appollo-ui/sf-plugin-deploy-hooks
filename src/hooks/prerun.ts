import { Hook } from '@oclif/core';
import { getPreDeployHooks } from '../utils/config-loader.js';
import { executeHooks } from '../utils/executor.js';

/**
 * Pre-run hook that executes bash scripts before deploy commands.
 * 
 * This hook intercepts deploy-related commands and runs pre-deploy hooks
 * configured in .sfhooks.json or sf-hooks.json, with fallback to ./hooks/pre-deploy.sh
 */
const hook: Hook.Prerun = async function (options) {
  const commandId = options.Command?.id;
  
  if (!commandId) {
    return;
  }

  // List of deploy-related commands that should trigger the pre-deploy hooks
  const deployCommands = [
    'project:deploy:start',
    'project:deploy:validate',
    'project:deploy:quick',
    'project:deploy:resume',
    'project:deploy:cancel',
    'project:deploy:report',
  ];

  // Check if the current command is a deploy command
  const isDeployCommand = deployCommands.some(cmd => 
    commandId === cmd || commandId.startsWith('project:deploy')
  );

  if (!isDeployCommand) {
    return;
  }

  const cwd = process.cwd();
  const hooks = getPreDeployHooks(cwd);

  if (hooks.length === 0) {
    this.debug?.('No pre-deploy hooks configured, skipping...');
    return;
  }

  this.log?.(`🔧 Running ${hooks.length} pre-deploy hook(s)...`);

  try {
    executeHooks(hooks, commandId, cwd, undefined, { log: this.log, debug: this.debug });
    this.log?.('✅ Pre-deploy hooks completed successfully');
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    this.error?.(`❌ Pre-deploy hook failed: ${message}`);
    
    // Re-throw to prevent the deploy command from running
    throw error;
  }
};

export default hook;
