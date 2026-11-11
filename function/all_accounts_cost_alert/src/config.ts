export type Config = {
  managementAccountId: string;
  readerRoleName: string;
  region: string;
  slackWebhookParameterName: string;
  increaseRatioThreshold: number;
  increaseUsdThreshold: number;
};

function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`environment variable ${name} is not set`);
  }
  return value;
}

function requireNumberEnv(name: string): number {
  const value = Number(requireEnv(name));
  if (!Number.isFinite(value) || value < 0) {
    throw new Error(`environment variable ${name} must be a non-negative number`);
  }
  return value;
}

export function loadConfig(): Config {
  return {
    managementAccountId: requireEnv("MANAGEMENT_ACCOUNT_ID"),
    readerRoleName: requireEnv("READER_ROLE_NAME"),
    region: requireEnv("AWS_REGION"),
    slackWebhookParameterName: requireEnv("PARAMETER_NAME_SLACK_WEBHOOK_URL"),
    increaseRatioThreshold: requireNumberEnv("INCREASE_RATIO_THRESHOLD"),
    increaseUsdThreshold: requireNumberEnv("INCREASE_USD_THRESHOLD"),
  };
}
