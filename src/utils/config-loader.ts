import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import type { HooksConfig } from '../types/config.js';

/**
 * Config file names to search for (in order of preference)
 */
const CONFIG_FILES = ['.sfhooks.json', 'sf-hooks.json'];

/**
 * Loads hook configuration from JSON file
 * 
 * @param cwd - Current working directory
 * @returns Parsed configuration or null if not found
 */
export function loadHooksConfig(cwd: string = process.cwd()): HooksConfig | null {
  for (const configFile of CONFIG_FILES) {
    const configPath = resolve(cwd, configFile);
    
    if (existsSync(configPath)) {
      try {
        const content = readFileSync(configPath, 'utf-8');
        const config = JSON.parse(content) as HooksConfig;
        return config;
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        throw new Error(`Failed to parse ${configFile}: ${message}`);
      }
    }
  }
  
  return null;
}

/**
 * Gets pre-deploy hooks from config, falling back to legacy script
 * 
 * @param cwd - Current working directory
 * @returns Array of pre-deploy script paths
 */
export function getPreDeployHooks(cwd: string = process.cwd()): string[] {
  const config = loadHooksConfig(cwd);
  
  if (config?.hooks?.preDeploy) {
    return config.hooks.preDeploy;
  }
  
  // Fallback: check for legacy script
  const legacyScript = resolve(cwd, './hooks/pre-deploy.sh');
  if (existsSync(legacyScript)) {
    return [legacyScript];
  }
  
  return [];
}

/**
 * Gets post-deploy hooks from config
 * 
 * @param cwd - Current working directory
 * @returns Array of post-deploy script paths
 */
export function getPostDeployHooks(cwd: string = process.cwd()): string[] {
  const config = loadHooksConfig(cwd);
  return config?.hooks?.postDeploy || [];
}
