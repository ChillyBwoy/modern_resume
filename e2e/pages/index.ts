import { test as testBase } from "@playwright/test";
import { LoginPage } from "./LoginPage";
import { RegistrationPage } from "./RegistrationPage";
import { CVListPage } from "./CVListPage";
import { CVCreatePage } from "./CVCreatePage";

type Pages = {
  loginPage: LoginPage;
  registrationPage: RegistrationPage;
  cvListPage: CVListPage;
  cvCreatePage: CVCreatePage;
};

export const test = testBase.extend<Pages>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  registrationPage: async ({ page }, use) => {
    await use(new RegistrationPage(page));
  },
  cvListPage: async ({ page }, use) => {
    await use(new CVListPage(page));
  },
  cvCreatePage: async ({ page }, use) => {
    await use(new CVCreatePage(page));
  },
});
