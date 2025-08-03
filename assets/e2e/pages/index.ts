import { test as testBase } from "@playwright/test";
import { LoginPage } from "./LoginPage.page";

type Pages = {
  loginPage: LoginPage;
};

export const test = testBase.extend<Pages>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
});
