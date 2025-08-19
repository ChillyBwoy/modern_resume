import { expect, Page } from "@playwright/test";

export const sync = async (page: Page) => {
  const promises = [
    expect(page.locator(".phx-connected").first()).toBeVisible(),
    expect(page.locator(".phx-change-loading")).toHaveCount(0),
    expect(page.locator(".phx-click-loading")).toHaveCount(0),
    expect(page.locator(".phx-submit-loading")).toHaveCount(0),
  ];
  return Promise.all(promises);
};
