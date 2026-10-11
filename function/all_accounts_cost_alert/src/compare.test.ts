import { describe, expect, it } from "vitest";
import { compareByAccount, selectIncreased } from "./compare";
import type { DailyAccountCost } from "./cost";

const period = {
  current: { start: "2026-09-28", end: "2026-10-05" },
  previous: { start: "2026-09-21", end: "2026-09-28" },
};

function cost(
  accountId: string,
  day: string,
  amountUsd: number,
  service = "AWS Lambda",
): DailyAccountCost {
  return { accountId, accountName: `acct-${accountId}`, service, day, amountUsd };
}

describe("compareByAccount", () => {
  it("アカウントごとに先週・前週を合計し、増加額の大きい順に並べる", () => {
    const result = compareByAccount(
      [
        cost("111", "2026-09-21", 10),
        cost("111", "2026-09-27", 10),
        cost("111", "2026-09-28", 15),
        cost("111", "2026-10-04", 15),
        cost("222", "2026-09-22", 100),
        cost("222", "2026-09-30", 150),
      ],
      period,
    );

    expect(result.map((c) => c.accountId)).toEqual(["222", "111"]);
    expect(result[0]).toMatchObject({
      accountName: "acct-222",
      previousUsd: 100,
      currentUsd: 150,
      increaseUsd: 50,
      increaseRatio: 0.5,
    });
    expect(result[1]).toMatchObject({ previousUsd: 20, currentUsd: 30, increaseUsd: 10 });
  });

  it("アカウント内をサービス別にも集計し、増加額の大きい順に並べる", () => {
    const [result] = compareByAccount(
      [
        cost("111", "2026-09-22", 10, "Amazon EC2"),
        cost("111", "2026-09-29", 40, "Amazon EC2"),
        cost("111", "2026-09-22", 5, "AWS Lambda"),
        cost("111", "2026-09-29", 6, "AWS Lambda"),
        cost("111", "2026-09-22", 20, "Amazon RDS"),
        cost("111", "2026-09-29", 10, "Amazon RDS"),
      ],
      period,
    );

    expect(result).toMatchObject({ previousUsd: 35, currentUsd: 56, increaseUsd: 21 });
    expect(result.services.map((s) => s.service)).toEqual([
      "Amazon EC2",
      "AWS Lambda",
      "Amazon RDS",
    ]);
    expect(result.services[0]).toMatchObject({
      previousUsd: 10,
      currentUsd: 40,
      increaseUsd: 30,
      increaseRatio: 3,
    });
  });

  it("前週が 0 のアカウントは増加率を Infinity にする", () => {
    const [result] = compareByAccount([cost("333", "2026-10-01", 5)], period);

    expect(result.increaseRatio).toBe(Infinity);
  });
});

describe("selectIncreased", () => {
  const thresholds = { increaseRatioThreshold: 0.2, increaseUsdThreshold: 10 };
  const base = { accountId: "x", accountName: "x", previousUsd: 0, currentUsd: 0, services: [] };

  it("増加率と増加額の両方がしきい値以上のものだけ残す", () => {
    const result = selectIncreased(
      [
        { ...base, accountId: "both", increaseUsd: 50, increaseRatio: 0.5 },
        { ...base, accountId: "ratio-only", increaseUsd: 5, increaseRatio: 0.9 },
        { ...base, accountId: "usd-only", increaseUsd: 500, increaseRatio: 0.1 },
        { ...base, accountId: "decreased", increaseUsd: -30, increaseRatio: -0.3 },
      ],
      thresholds,
    );

    expect(result.map((c) => c.accountId)).toEqual(["both"]);
  });

  it("前週 0 からの新規発生は増加額がしきい値以上なら残す", () => {
    const result = selectIncreased(
      [{ ...base, accountId: "new", increaseUsd: 12, increaseRatio: Infinity }],
      thresholds,
    );

    expect(result).toHaveLength(1);
  });
});
