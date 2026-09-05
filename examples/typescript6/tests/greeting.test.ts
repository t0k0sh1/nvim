import { describe, expect, it } from "vitest";

import { greet } from "../src/greeting";

describe("greet", () => {
  it("greets by name", () => {
    expect(greet("TypeScript")).toBe("Hello, TypeScript!");
  });
});
