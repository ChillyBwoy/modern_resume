import { Locator, Page } from "@playwright/test";

export class LoginPage {
  readonly fieldEmail: Locator;
  readonly fieldPassword: Locator;

  readonly labelEmail: Locator;
  readonly labelPassword: Locator;

  readonly inputEmail: Locator;
  readonly inputPassword: Locator;

  readonly buttonSignin: Locator;
  readonly buttonSigninGithub: Locator;
  readonly buttonSigninGoogle: Locator;

  constructor(protected readonly page: Page) {
    this.fieldEmail = page.getByTestId("email");
    this.fieldPassword = page.getByTestId("password");

    this.labelEmail = this.fieldEmail.getByTestId("form-field-label");
    this.labelPassword = this.fieldPassword.getByTestId("form-field-label");

    this.inputEmail = this.fieldEmail.locator("input");
    this.inputPassword = this.fieldPassword.locator("input[type='password']");

    this.buttonSignin = page.getByTestId("button-signin");
    this.buttonSigninGithub = page.getByTestId("button-signin-github");
    this.buttonSigninGoogle = page.getByTestId("button-signin-google");
  }

  get url() {
    return "/users/log_in";
  }

  async goto() {
    await this.page.goto(this.url);
  }

  async login(email: string, password: string) {
    await this.inputEmail.fill(email);
    await this.inputPassword.fill(password);
    await this.buttonSignin.click();
  }
}
