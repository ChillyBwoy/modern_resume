import { expect, Page } from "@playwright/test";

export const ensurePageIsLoaded = async (page: Page) =>
  Promise.all([
    expect(page.locator(".phx-connected").first()).toBeVisible(),
    expect(page.locator(".phx-change-loading")).toHaveCount(0),
    expect(page.locator(".phx-click-loading")).toHaveCount(0),
    expect(page.locator(".phx-keydown-loading")).toHaveCount(0),
    expect(page.locator(".phx-submit-loading")).toHaveCount(0),
  ]);
