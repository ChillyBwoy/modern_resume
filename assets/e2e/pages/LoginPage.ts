import { Locator, Page } from "@playwright/test";

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly signinButton: Locator;
  readonly signinGithubButton: Locator;
  readonly signinGoogleButton: Locator;

  constructor(protected readonly page: Page) {
    this.emailInput = page.locator("input[name='user[email]']");
    this.passwordInput = page.locator("input[name='user[password]']");
    this.signinButton = page.getByTestId("signin_button");
    this.signinGithubButton = page.getByTestId("signin_github");
    this.signinGoogleButton = page.getByTestId("signin_google");
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
