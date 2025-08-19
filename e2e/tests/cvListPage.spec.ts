import { expect } from "@playwright/test";
import { test } from "../pages";
import { E2E_USER_EMAIL, E2E_USER_PASSWORD } from "../common/constants";
import { sync } from "../common/syncLV";

test.describe("CV List Page", () => {
  test.beforeEach(async ({ page, loginPage }) => {
    await loginPage.goto();
    await loginPage.login(E2E_USER_EMAIL, E2E_USER_PASSWORD);
    await sync(page);
  });

  test("1. Should open cv list page", async ({ page, cvListPage }) => {
    await expect(page).toHaveURL(cvListPage.url);
    await expect(cvListPage.pageTitle).toHaveText("My CVs");
    await expect(cvListPage.addNewCVButton).toContainText("Create New CV");
  });

  test("2. Can click button Create New CV", async ({
    page,
    cvListPage,
    cvCreatePage,
  }) => {
    await cvListPage.addNewCVButton.click();
    await sync(page);
    await expect(page).toHaveURL(cvCreatePage.url);
  });

  test("3. Create New CV page has title", async ({
    page,
    cvListPage,
    cvCreatePage,
  }) => {
    await cvListPage.addNewCVButton.click();
    await sync(page);
    await expect(cvCreatePage.pageTitle).toHaveText("Create new CV");
  });
});
