import { expect } from "@playwright/test";
import { test } from "../pages";
import { E2E_USER_EMAIL, E2E_USER_PASSWORD } from "../common/constants";

test.describe("User Registration Page", () => {
  test.describe.configure({ mode: "serial" });

  test.beforeEach(async ({ registrationPage }) => {
    await registrationPage.goto();
  });

  test("should show an error when trying to register with an existing user", async ({
    registrationPage,
  }) => {
    await registrationPage.register(
      E2E_USER_EMAIL,
      E2E_USER_PASSWORD,
      E2E_USER_PASSWORD
    );

    await expect(registrationPage.formError).toHaveText(
      "Oops, something went wrong! Please check the errors below."
    );
    await expect(registrationPage.formEmailError).toHaveText(
      "has already been taken"
    );
  });

  test("should show an error when trying to register with invalid email", async ({
    registrationPage,
  }) => {
    await registrationPage.register(
      "notemail",
      E2E_USER_PASSWORD,
      E2E_USER_PASSWORD
    );
    await expect(registrationPage.formEmailError).toHaveText(
      "must have the @ sign and no spaces"
    );
  });

  test("should show an error when trying to register with too short password", async ({
    registrationPage,
  }) => {
    await registrationPage.register(E2E_USER_EMAIL, "password", "password");
    await expect(registrationPage.formPasswordError).toHaveText(
      "should be at least 12 character(s)"
    );
  });

  test("should show an error when trying to register with invalid password confirmation", async ({
    registrationPage,
  }) => {
    await registrationPage.register(
      E2E_USER_EMAIL,
      "passwordpassword",
      "password"
    );
    await expect(registrationPage.formPasswordConfirmationError).toHaveText(
      "does not match password"
    );
  });
});
