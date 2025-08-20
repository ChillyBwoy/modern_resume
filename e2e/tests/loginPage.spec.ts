import { expect } from "@playwright/test";
import { test } from "../pages";
import { ensurePageIsLoaded } from "../common/page";

test.describe("Login Page", () => {
  test("1. Should render login page", async ({ page, loginPage }) => {
    await loginPage.goto();
    await ensurePageIsLoaded(page);
    await expect(page).toHaveURL(loginPage.url);

    await expect(loginPage.labelEmail).toHaveText("Email");
    await expect(loginPage.labelPassword).toHaveText("Password");

    await expect(loginPage.inputEmail).toBeVisible();
    await expect(loginPage.inputPassword).toBeVisible();

    await expect(loginPage.buttonSignin).toBeVisible();
    await expect(loginPage.buttonSigninGithub).toBeVisible();
    await expect(loginPage.buttonSigninGoogle).toBeVisible();
  });
});
