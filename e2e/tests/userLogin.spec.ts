import { expect } from "@playwright/test";
import { test } from "../pages";

test.describe("Login Page", () => {
  test("should open login page", async ({ page, loginPage }) => {
    await loginPage.goto();
    await expect(page).toHaveURL(loginPage.url);

    await expect(loginPage.signinButton).toBeVisible();
    await expect(loginPage.signinGithubButton).toBeVisible();
    await expect(loginPage.signinGoogleButton).toBeVisible();
  });
});
