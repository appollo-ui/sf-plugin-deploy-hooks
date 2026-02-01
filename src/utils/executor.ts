import { execSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

/**
 * Executes a hook script
 * 
 * @param scriptPath - Path to the script (relative or absolute)
 * @param commandId - The SF command ID
 * @param cwd - Current working directory
 * @param resultFilePath - Optional path to deploy result JSON file
 * @param logger - Optional logger functions
 */
export function executeHook(
  scriptPath: string,
  commandId: string,
  cwd: string = process.cwd(),
  resultFilePath?: string,
  logger?: { log?: (message: string) => void; debug?: (message: string) => void }
): void {
  const resolvedPath = resolve(cwd, scriptPath);
  
  if (!existsSync(resolvedPath)) {
    throw new Error(`Hook script not found: ${resolvedPath}`);
  }
  
  logger?.log?.(`🔧 Running hook: ${scriptPath}`);
  
  const env: Record<string, string> = {
    ...process.env,
    SF_COMMAND: commandId,
  };
  
  if (resultFilePath) {
    env.SF_DEPLOY_RESULT_FILE = resultFilePath;
  }
  
  execSync(`bash "${resolvedPath}"`, {
    stdio: 'inherit',
    cwd,
    env,
  });
}

/**
 * Executes multiple hook scripts sequentially
 * 
 * @param scripts - Array of script paths
 * @param commandId - The SF command ID
 * @param cwd - Current working directory
 * @param resultFilePath - Optional path to deploy result JSON file
 * @param logger - Optional logger functions
 * @returns Number of scripts executed
 */
export function executeHooks(
  scripts: string[],
  commandId: string,
  cwd: string = process.cwd(),
  resultFilePath?: string,
  logger?: { log?: (message: string) => void; debug?: (message: string) => void }
): number {
  let executed = 0;
  
  for (const script of scripts) {
    executeHook(script, commandId, cwd, resultFilePath, logger);
    executed++;
  }
  
  return executed;
}
