import { Locator, Page } from "@playwright/test";

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly signinButton: Locator;
  readonly signinGithubButton: Locator;
  readonly signinGoogleButton: Locator;

  constructor(protected readonly page: Page) {
    this.emailInput = page.getByTestId("input-email");
    this.passwordInput = page.getByTestId("input-password");
    this.signinButton = page.getByTestId("button-signin");
    this.signinGithubButton = page.getByTestId("button-signin-github");
    this.signinGoogleButton = page.getByTestId("button-signin-google");
  }

  get url() {
    return "/users/log_in";
  }

  async goto() {
    await this.page.goto(this.url);
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.signinButton.click();
  }
}
