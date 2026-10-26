import { describe, expect, it } from "vitest";
import { isInRange, resolveComparisonPeriod } from "./period";

describe("resolveComparisonPeriod", () => {
  it("実行日の前日までの 7 日間と、その前の 7 日間に分ける", () => {
    const period = resolveComparisonPeriod(new Date("2026-10-05T00:30:00Z"));

    expect(period.current).toEqual({ start: "2026-09-28", end: "2026-10-05" });
    expect(period.previous).toEqual({ start: "2026-09-21", end: "2026-09-28" });
  });

  it("月をまたいでも日数は 7 日ずつになる", () => {
    const period = resolveComparisonPeriod(new Date("2026-03-02T09:00:00Z"));

    expect(period.current).toEqual({ start: "2026-02-23", end: "2026-03-02" });
    expect(period.previous).toEqual({ start: "2026-02-16", end: "2026-02-23" });
  });
});

describe("isInRange", () => {
  const range = { start: "2026-09-28", end: "2026-10-05" };

  it("start は含み end は含まない", () => {
    expect(isInRange("2026-09-28", range)).toBe(true);
    expect(isInRange("2026-10-04", range)).toBe(true);
    expect(isInRange("2026-10-05", range)).toBe(false);
    expect(isInRange("2026-09-27", range)).toBe(false);
  });
});
