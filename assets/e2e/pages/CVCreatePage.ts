import { Locator, Page } from "@playwright/test";

export class CVCreatePage {
  readonly pageTitle: Locator;

  constructor(protected readonly page: Page) {
    this.pageTitle = page.getByRole("heading", { name: "Create new CV" });
  }

  get url() {
    return "/cvs/new";
  }
}
