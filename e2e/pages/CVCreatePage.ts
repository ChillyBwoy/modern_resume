import { Locator, Page } from "@playwright/test";

export class CVCreatePage {
  readonly modal: Locator;
  readonly modalTitle: Locator;

  readonly fieldTitle: Locator;
  readonly fieldName: Locator;
  readonly fieldPosition: Locator;

  readonly labelTitle: Locator;
  readonly labelName: Locator;
  readonly labelPosition: Locator;

  readonly inputTitle: Locator;
  readonly inputName: Locator;
  readonly inputPosition: Locator;

  constructor(protected readonly page: Page) {
    this.modal = page.getByTestId("create-new-cv-modal");

    this.modalTitle = this.modal.getByTestId("modal-dailog-title");

    this.fieldTitle = this.modal.getByTestId("title");
    this.fieldName = this.modal.getByTestId("name");
    this.fieldPosition = this.modal.getByTestId("position");

    this.labelTitle = this.fieldTitle.getByTestId("form-field-label");
    this.labelName = this.fieldName.getByTestId("form-field-label");
    this.labelPosition = this.fieldPosition.getByTestId("form-field-label");

    this.inputTitle = this.fieldTitle.locator("input");
    this.inputName = this.fieldName.locator("input");
    this.inputPosition = this.fieldPosition.locator("input");
  }

  get url() {
    return "/cvs/new";
  }

  async goto() {
    await this.page.goto(this.url);
  }
}
