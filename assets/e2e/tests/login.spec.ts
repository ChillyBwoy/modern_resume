import { expect } from "@playwright/test";
import { test } from "../pages";

test.describe("Login Page", () => {
  test("should open login page", async ({ page, loginPage }) => {
    await loginPage.goto();
    await expect(page).toHaveURL(loginPage.url);
  });
});
