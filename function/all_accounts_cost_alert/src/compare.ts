import type { DailyAccountCost } from "./cost";
import { type ComparisonPeriod, isInRange } from "./period";

export type CostChange = {
  previousUsd: number;
  currentUsd: number;
  increaseUsd: number;
  increaseRatio: number;
};

export type ServiceComparison = CostChange & {
  service: string;
};

export type AccountComparison = CostChange & {
  accountId: string;
  accountName: string;
  services: ServiceComparison[];
};

export type Thresholds = {
  increaseRatioThreshold: number;
  increaseUsdThreshold: number;
};

type Sums = { previousUsd: number; currentUsd: number };

function toChange(sums: Sums): CostChange {
  const increaseUsd = sums.currentUsd - sums.previousUsd;
  const increaseRatio = sums.previousUsd === 0 ? Infinity : increaseUsd / sums.previousUsd;
  return { ...sums, increaseUsd, increaseRatio };
}

function addTo(sums: Sums, cost: DailyAccountCost, period: ComparisonPeriod): void {
  if (isInRange(cost.day, period.current)) {
    sums.currentUsd += cost.amountUsd;
  } else if (isInRange(cost.day, period.previous)) {
    sums.previousUsd += cost.amountUsd;
  }
}

function byIncreaseDesc<T extends CostChange>(a: T, b: T): number {
  return b.increaseUsd - a.increaseUsd;
}

export function compareByAccount(
  costs: DailyAccountCost[],
  period: ComparisonPeriod,
): AccountComparison[] {
  const accounts = new Map<
    string,
    { accountName: string; total: Sums; services: Map<string, Sums> }
  >();
  for (const cost of costs) {
    const account = accounts.get(cost.accountId) ?? {
      accountName: cost.accountName,
      total: { previousUsd: 0, currentUsd: 0 },
      services: new Map<string, Sums>(),
    };
    const service = account.services.get(cost.service) ?? { previousUsd: 0, currentUsd: 0 };
    addTo(account.total, cost, period);
    addTo(service, cost, period);
    account.services.set(cost.service, service);
    accounts.set(cost.accountId, account);
  }

  return [...accounts.entries()]
    .map(([accountId, account]) => ({
      accountId,
      accountName: account.accountName,
      ...toChange(account.total),
      services: [...account.services.entries()]
        .map(([service, sums]) => ({ service, ...toChange(sums) }))
        .sort(byIncreaseDesc),
    }))
    .sort(byIncreaseDesc);
}

export function selectIncreased(
  comparisons: AccountComparison[],
  thresholds: Thresholds,
): AccountComparison[] {
  return comparisons.filter(
    (c) =>
      c.increaseUsd >= thresholds.increaseUsdThreshold &&
      c.increaseRatio >= thresholds.increaseRatioThreshold,
  );
}
