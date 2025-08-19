import { Locator, Page } from "@playwright/test";

export class RegistrationPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly passwordConfirmationInput: Locator;
  readonly submitButton: Locator;
  readonly formError: Locator;
  readonly formEmailError: Locator;
  readonly formPasswordError: Locator;
  readonly formPasswordConfirmationError: Locator;

  constructor(protected readonly page: Page) {
    this.emailInput = page.locator("#user_email");
    this.passwordInput = page.locator("#user_password");
    this.passwordConfirmationInput = page.locator(
      "#user_password_confirmation"
    );
    this.submitButton = page.getByRole("button", { name: "Create an account" });
    this.formError = page.getByTestId("registration-error");
    this.formEmailError = page.getByTestId("user_email-error-0");
    this.formPasswordError = page.getByTestId("user_password-error-0");
    this.formPasswordConfirmationError = page.getByTestId(
      "user_password_confirmation-error-0"
    );
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
