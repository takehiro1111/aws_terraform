import type { ScheduledHandler } from "aws-lambda";
import { compareByAccount, selectIncreased } from "./compare";
import { loadConfig } from "./config";
import { fetchDailyAccountCosts } from "./cost";
import { buildMessage } from "./message";
import { resolveComparisonPeriod } from "./period";
import { getWebhookUrl, postToSlack } from "./slack";

export const handler: ScheduledHandler = async () => {
  const config = loadConfig();
  const period = resolveComparisonPeriod(new Date());
  const costs = await fetchDailyAccountCosts(config, period);
  const comparisons = compareByAccount(costs, period);
  const increased = selectIncreased(comparisons, config);
  console.log(
    JSON.stringify({ period, accounts: comparisons.length, increased: increased.length }),
  );

  const webhookUrl = await getWebhookUrl(config.slackWebhookParameterName, config.region);
  await postToSlack(webhookUrl, buildMessage(period, increased, comparisons));
};
