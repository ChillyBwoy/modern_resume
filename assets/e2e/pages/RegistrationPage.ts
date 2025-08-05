import { Locator, Page } from "@playwright/test";

export class RegistrationPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly passwordConfirmationInput: Locator;
  readonly submitButton: Locator;

  constructor(protected readonly page: Page) {
    this.emailInput = page.locator("#user_email");
    this.passwordInput = page.locator("#user_password");
    this.passwordConfirmationInput = page.locator(
      "#user_password_confirmation"
    );
    this.submitButton = page.getByRole("button", { name: "Create an account" });
  }

  get url() {
    return "/users/register";
  }

  async goto() {
    await this.page.goto(this.url);
  }

  async register(
    email: string,
    password: string,
    passwordConfirmation: string
  ) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.passwordConfirmationInput.fill(passwordConfirmation);
    await this.submitButton.click();
  }
}
