import { describe, expect, it } from "vitest";
import type { AccountComparison, ServiceComparison } from "./compare";
import { buildMessage } from "./message";

const period = {
  current: { start: "2026-09-28", end: "2026-10-05" },
  previous: { start: "2026-09-21", end: "2026-09-28" },
};

function service(name: string, previousUsd: number, currentUsd: number): ServiceComparison {
  const increaseUsd = currentUsd - previousUsd;
  return {
    service: name,
    previousUsd,
    currentUsd,
    increaseUsd,
    increaseRatio: previousUsd === 0 ? Infinity : increaseUsd / previousUsd,
  };
}

function account(
  accountId: string,
  accountName: string,
  previousUsd: number,
  currentUsd: number,
  services: ServiceComparison[] = [],
): AccountComparison {
  const increaseUsd = currentUsd - previousUsd;
  return {
    accountId,
    accountName,
    previousUsd,
    currentUsd,
    increaseUsd,
    increaseRatio: previousUsd === 0 ? Infinity : increaseUsd / previousUsd,
    services,
  };
}

describe("buildMessage", () => {
  it("見出し・前週比のまとめ・アカウント一覧の 3 セクションに分け、増えたアカウントに印と増えたサービスを付ける", () => {
    const increased = [
      account("111", "TRIPLE LIST Test", 100, 150.5, [
        service("Amazon EC2", 50, 90),
        service("AWS Lambda", 10, 20.5),
        service("Amazon RDS", 40, 40),
      ]),
    ];
    const all = [...increased, account("222", "SANDBOX", 1000, 900, [service("Amazon EC2", 1000, 900)])];

    const { text, blocks } = buildMessage(period, increased, all);

    expect(blocks).toHaveLength(3);
    expect(blocks[0].text.text).toBe(
      ":money_mouth_face: *先週 (2026-09-28 〜 2026-10-04) の AWS コスト*",
    );
    expect(blocks[1].text.text).toBe(
      [
        "前週 (2026-09-21 〜 2026-09-27) より増えたアカウント: 1 件",
        "全体: $1,100.00 → $1,050.50 (-$49.50 / -5%)",
      ].join("\n"),
    );
    expect(blocks[2].text.text).toBe(
      [
        ":small_red_triangle: *TRIPLE LIST Test* (111)",
        "$100.00 → $150.50 (+$50.50 / +51%)",
        "• Amazon EC2: $50.00 → $90.00 (+$40.00 / +80%)",
        "• AWS Lambda: $10.00 → $20.50 (+$10.50 / +105%)",
        "",
        "*SANDBOX* (222)",
        "$1,000.00 → $900.00 (-$100.00 / -10%)",
      ].join("\n"),
    );
    expect(text.split("\n")).toHaveLength(9);
  });

  it("増えたサービスは増加額の上位 3 件までにする", () => {
    const all = [
      account("111", "a", 0, 10, [
        service("s1", 0, 4),
        service("s2", 0, 3),
        service("s3", 0, 2),
        service("s4", 0, 1),
      ]),
    ];

    const { blocks } = buildMessage(period, [], all);
    const lines = blocks[2].text.text.split("\n");

    expect(lines.filter((l) => l.startsWith("• "))).toEqual([
      "• s1: $0.00 → $4.00 (+$4.00 / 新規)",
      "• s2: $0.00 → $3.00 (+$3.00 / 新規)",
      "• s3: $0.00 → $2.00 (+$2.00 / 新規)",
    ]);
  });

  it("増えたアカウントが無くても全アカウントを出し、件数は 0 件になる", () => {
    const all = [account("222", "SANDBOX", 10, 10, [service("AWS Lambda", 10, 10)])];

    const { blocks } = buildMessage(period, [], all);

    expect(blocks[1].text.text).toContain("0 件");
    expect(blocks[2].text.text).toBe("*SANDBOX* (222)\n$10.00 → $10.00 (+$0.00 / +0%)");
  });
});
