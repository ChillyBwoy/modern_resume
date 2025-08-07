import { test as testBase } from "@playwright/test";
import { LoginPage } from "./LoginPage";
import { RegistrationPage } from "./RegistrationPage";

type Pages = {
  loginPage: LoginPage;
  registrationPage: RegistrationPage;
};

export const test = testBase.extend<Pages>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  registrationPage: async ({ page }, use) => {
    await use(new RegistrationPage(page));
  },
});
