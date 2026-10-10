import type { AccountComparison, CostChange } from "./compare";
import type { ComparisonPeriod, DateRange } from "./period";

export type SlackMessage = {
  text: string;
  blocks: { type: "section"; text: { type: "mrkdwn"; text: string } }[];
};

const MS_PER_DAY = 24 * 60 * 60 * 1000;
const SERVICES_PER_ACCOUNT = 3;

function formatUsd(amount: number): string {
  return `$${amount.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function formatSignedUsd(amount: number): string {
  return `${amount < 0 ? "-" : "+"}${formatUsd(Math.abs(amount))}`;
}

function formatRatio(ratio: number): string {
  if (!Number.isFinite(ratio)) return "新規";
  const percent = Math.round(Math.abs(ratio) * 100);
  return `${ratio < 0 ? "-" : "+"}${percent}%`;
}

function formatRange(range: DateRange): string {
  const lastDay = new Date(new Date(range.end).getTime() - MS_PER_DAY).toISOString().slice(0, 10);
  return `${range.start} 〜 ${lastDay}`;
}

function formatChange(change: CostChange): string {
  return `${formatUsd(change.previousUsd)} → ${formatUsd(change.currentUsd)} (${formatSignedUsd(change.increaseUsd)} / ${formatRatio(change.increaseRatio)})`;
}

export function buildMessage(
  period: ComparisonPeriod,
  increased: AccountComparison[],
  all: AccountComparison[],
): SlackMessage {
  const total = (select: (c: AccountComparison) => number) =>
    all.reduce((sum, c) => sum + select(c), 0);
  const totalPrevious = total((c) => c.previousUsd);
  const totalCurrent = total((c) => c.currentUsd);
  const totalChange: CostChange = {
    previousUsd: totalPrevious,
    currentUsd: totalCurrent,
    increaseUsd: totalCurrent - totalPrevious,
    increaseRatio:
      totalPrevious === 0 ? Infinity : (totalCurrent - totalPrevious) / totalPrevious,
  };
  const increasedIds = new Set(increased.map((c) => c.accountId));

  const header = `:money_mouth_face: *先週 (${formatRange(period.current)}) の AWS コスト*`;
  const summary = [
    `前週 (${formatRange(period.previous)}) より増えたアカウント: ${increased.length} 件`,
    `全体: ${formatChange(totalChange)}`,
  ];
  const accounts = all.map((c) => {
    const mark = increasedIds.has(c.accountId) ? ":small_red_triangle: " : "";
    const increasedServices = c.services
      .filter((s) => s.increaseUsd > 0)
      .slice(0, SERVICES_PER_ACCOUNT)
      .map((s) => `• ${s.service}: ${formatChange(s)}`);
    return [`${mark}*${c.accountName}* (${c.accountId})`, formatChange(c), ...increasedServices].join(
      "\n",
    );
  });

  const sections = [header, summary.join("\n"), accounts.join("\n\n")];
  return {
    text: [header, ...summary, ...accounts].join("\n"),
    blocks: sections.map((text) => ({ type: "section", text: { type: "mrkdwn", text } })),
  };
}
