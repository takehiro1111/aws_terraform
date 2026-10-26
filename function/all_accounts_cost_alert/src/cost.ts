import {
  CostExplorerClient,
  GetCostAndUsageCommand,
  type GetCostAndUsageCommandInput,
} from "@aws-sdk/client-cost-explorer";
import { fromTemporaryCredentials } from "@aws-sdk/credential-providers";
import type { ComparisonPeriod } from "./period";

export type DailyAccountCost = {
  accountId: string;
  accountName: string;
  service: string;
  day: string;
  amountUsd: number;
};

type Reader = {
  managementAccountId: string;
  readerRoleName: string;
  region: string;
};

// NOTE: Cost Explorer のエンドポイントは us-east-1 にしかない
const COST_EXPLORER_REGION = "us-east-1";

export async function fetchDailyAccountCosts(
  reader: Reader,
  period: ComparisonPeriod,
): Promise<DailyAccountCost[]> {
  const credentials = fromTemporaryCredentials({
    params: {
      RoleArn: `arn:aws:iam::${reader.managementAccountId}:role/${reader.readerRoleName}`,
      RoleSessionName: "all-accounts-cost-alert",
    },
    clientConfig: { region: reader.region },
  });
  const client = new CostExplorerClient({ region: COST_EXPLORER_REGION, credentials });

  const input: GetCostAndUsageCommandInput = {
    TimePeriod: { Start: period.previous.start, End: period.current.end },
    Granularity: "DAILY",
    Metrics: ["UnblendedCost"],
    GroupBy: [
      { Type: "DIMENSION", Key: "LINKED_ACCOUNT" },
      { Type: "DIMENSION", Key: "SERVICE" },
    ],
    Filter: {
      Not: {
        Dimensions: { Key: "RECORD_TYPE", Values: ["Credit", "Refund"] },
      },
    },
  };

  const costs: DailyAccountCost[] = [];
  const accountNames = new Map<string, string>();
  let nextPageToken: string | undefined;
  do {
    const result = await client.send(
      new GetCostAndUsageCommand({ ...input, NextPageToken: nextPageToken }),
    );
    for (const attribute of result.DimensionValueAttributes ?? []) {
      if (attribute.Value && attribute.Attributes?.description) {
        accountNames.set(attribute.Value, attribute.Attributes.description);
      }
    }
    for (const byTime of result.ResultsByTime ?? []) {
      const day = byTime.TimePeriod?.Start;
      if (!day) continue;
      for (const group of byTime.Groups ?? []) {
        const accountId = group.Keys?.[0];
        const service = group.Keys?.[1];
        const amount = group.Metrics?.UnblendedCost?.Amount;
        if (!accountId || !service || amount === undefined) continue;
        costs.push({
          accountId,
          accountName: accountNames.get(accountId) ?? accountId,
          service,
          day,
          amountUsd: Number(amount),
        });
      }
    }
    nextPageToken = result.NextPageToken;
  } while (nextPageToken);

  return costs;
}
