/**
 * Configuration schema for deploy hooks
 */
export interface HooksConfig {
  hooks?: {
    preDeploy?: string[];
    postDeploy?: string[];
  };
}
