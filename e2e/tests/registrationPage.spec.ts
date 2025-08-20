import { expect } from "@playwright/test";
import { test } from "../pages";
import { E2E_USER_EMAIL, E2E_USER_PASSWORD } from "../common/constants";
import { ensurePageIsLoaded } from "../common/page";

test.describe("Registration Page", () => {
  test.describe.configure({ mode: "serial" });

  test.beforeEach(async ({ page, registrationPage }) => {
    await registrationPage.goto();
    await ensurePageIsLoaded(page);
  });

  test("1. Should show an error when trying to register with an existing user", async ({
    registrationPage,
  }) => {
    await registrationPage.register(
      E2E_USER_EMAIL,
      E2E_USER_PASSWORD,
      E2E_USER_PASSWORD
    );
    await expect(registrationPage.errorForm).toHaveText(
      "Oops, something went wrong! Please check the errors below."
    );
    await expect(registrationPage.errorEmail.first()).toHaveText(
      "has already been taken"
    );
  });

  test("2. Should show an error when trying to register with invalid email", async ({
    registrationPage,
  }) => {
    await registrationPage.register(
      "notemail",
      E2E_USER_PASSWORD,
      E2E_USER_PASSWORD
    );
    await expect(registrationPage.errorEmail.first()).toHaveText(
      "must have the @ sign and no spaces"
    );
  });

  test("3. Should show an error when trying to register with too short password", async ({
    registrationPage,
  }) => {
    await registrationPage.register(E2E_USER_EMAIL, "password", "password");
    await expect(registrationPage.errorPassword).toHaveText(
      "should be at least 12 character(s)"
    );
  });

  test("4. Should show an error when trying to register with invalid password confirmation", async ({
    registrationPage,
  }) => {
    await registrationPage.register(
      E2E_USER_EMAIL,
      "passwordpassword",
      "password"
    );
    await expect(registrationPage.errorPasswordConfirmation).toHaveText(
      "does not match password"
    );
  });
});
