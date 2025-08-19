import { Locator, Page } from "@playwright/test";

export class RegistrationPage {
  readonly fieldEmail: Locator;
  readonly fieldPassword: Locator;
  readonly fieldPasswordConfirmation: Locator;

  readonly labelEmail: Locator;
  readonly labelPassword: Locator;
  readonly labelPasswordConfirmation: Locator;

  readonly inputEmail: Locator;
  readonly inputPassword: Locator;
  readonly inputPasswordConfirmation: Locator;

  readonly buttonRegister: Locator;
  readonly buttonRegisterGithub: Locator;
  readonly buttonRegisterGoogle: Locator;

  readonly errorForm: Locator;
  readonly errorEmail: Locator;
  readonly errorPassword: Locator;
  readonly errorPasswordConfirmation: Locator;

  constructor(protected readonly page: Page) {
    this.fieldEmail = page.getByTestId("email");
    this.fieldPassword = page.getByTestId("password");
    this.fieldPasswordConfirmation = page.getByTestId("password-confirmation");

    this.labelEmail = this.fieldEmail.getByTestId("form-field-label");
    this.labelPassword = this.fieldPassword.getByTestId("form-field-label");
    this.labelPasswordConfirmation =
      this.fieldPasswordConfirmation.getByTestId("form-field-label");

    this.inputEmail = this.fieldEmail.locator("input");
    this.inputPassword = this.fieldPassword.locator("input[type='password']");
    this.inputPasswordConfirmation = this.fieldPasswordConfirmation.locator(
      "input[type='password']"
    );

    this.buttonRegister = page.getByTestId("button-register");
    this.buttonRegisterGithub = page.getByTestId("button-register-github");
    this.buttonRegisterGoogle = page.getByTestId("button-register-google");

    this.errorForm = page.getByTestId("error-form");

    this.errorEmail = this.fieldEmail.getByTestId("form-field-error");
    this.errorPassword = this.fieldPassword.getByTestId("form-field-error");
    this.errorPasswordConfirmation =
      this.fieldPasswordConfirmation.getByTestId("form-field-error");
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
    await this.inputEmail.fill(email);
    await this.inputPassword.fill(password);
    await this.inputPasswordConfirmation.fill(passwordConfirmation);
    await this.buttonRegister.click();
  }
}
