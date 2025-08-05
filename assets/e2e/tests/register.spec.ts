import { expect } from "@playwright/test";
import { test } from "../pages";
import { TEST_USER_EMAIL, TEST_USER_PASSWORD } from "../common/constants";

test.describe("Register Page", () => {
  test("should register new account", async ({ page, registrationPage }) => {
    await registrationPage.goto();
    await registrationPage.register(
      TEST_USER_EMAIL,
      TEST_USER_PASSWORD,
      TEST_USER_PASSWORD
    );
    await expect(page.getByTestId("error_message")).toHaveText(
      "Oops, something went wrong! Please check the errors below."
    );
  });
});
