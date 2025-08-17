import { Locator, Page } from "@playwright/test";

export class CVListPage {
  readonly pageTitle: Locator;
  readonly addNewCVButton: Locator;

  constructor(protected readonly page: Page) {
    this.pageTitle = page.getByRole("heading", { name: "My CVs" });
    this.addNewCVButton = page.getByRole("button", { name: "Create New CV" });
  }

  get url() {
    return "/";
  }

  async goto() {
    await this.page.goto(this.url);
  }
}
