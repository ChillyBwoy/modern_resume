import { Locator, Page } from "@playwright/test";

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;

  constructor(protected readonly page: Page) {
    this.emailInput = page.locator("input[name='user[email]']");
    this.passwordInput = page.locator("input[name='user[password]']");
  }

  get url() {
    return "/users/log_in";
  }

  async goto() {
    await this.page.goto(this.url);
  }
}
