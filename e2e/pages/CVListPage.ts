import { Locator, Page } from "@playwright/test";

export class CVListPage {
  readonly pageTitle: Locator;
  readonly addNewCVButton: Locator;

  constructor(protected readonly page: Page) {
    this.pageTitle = page.getByTestId("cv-list-page-title");
    this.addNewCVButton = page.getByTestId("button-create-new-cv");
  }

  get url() {
    return "/";
  }

  async goto() {
    await this.page.goto(this.url);
  }
}
