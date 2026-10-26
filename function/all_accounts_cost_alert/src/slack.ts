import { GetParameterCommand, SSMClient } from "@aws-sdk/client-ssm";
import type { SlackMessage } from "./message";

export async function getWebhookUrl(parameterName: string, region: string): Promise<string> {
  const client = new SSMClient({ region });
  const result = await client.send(
    new GetParameterCommand({ Name: parameterName, WithDecryption: true }),
  );
  if (!result.Parameter?.Value) {
    throw new Error(`parameter ${parameterName} has no value`);
  }
  return result.Parameter.Value;
}

export async function postToSlack(webhookUrl: string, message: SlackMessage): Promise<void> {
  const response = await fetch(webhookUrl, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(message),
  });
  if (!response.ok) {
    throw new Error(`Slack webhook returned ${response.status}: ${await response.text()}`);
  }
}
