import { Hook } from "phoenix_live_view";
import { createInputEvent, createSubmitEvent, useFormState } from "../lib/form";

const SELECTOR = {
  content: "[data-type='DateInputContent']",
  input: "[data-type='DateInputInput']",
} as const;

function validate(input: string) {
  if (input.length <= 4) {
    return /[0-9]{1,4}/.test(input);
  }

  if (input.length <= 5) {
    return /[0-9]{4}-/.test(input);
  }

  if (input.length <= 7) {
    return /[0-9]{4}-[0-9]{1,2}/.test(input);
  }

  if (input.length > 7) {
    return false;
  }

  return true;
}

export default (): Hook => ({
  mounted() {
    const $content = this.el.querySelector(SELECTOR.content) as HTMLElement;
    const $input = this.el.querySelector(SELECTOR.input) as HTMLInputElement;
    const $form = this.el.closest("form") as HTMLFormElement;

    const onSubmit = createSubmitEvent($form);
    const onInput = createInputEvent($input);

    const formState = useFormState($form);

    $content.addEventListener("input", (_event) => {
      const value = $content.innerText.trim();

      if (validate(value)) {
        const [year, month] = value.split("-");
        onInput(`${year}-${month}-01`);
      } else {
        $content.innerText = "";
        onInput("");
      }
    });

    $content.addEventListener("keydown", (event) => {
      if (event.key === "Escape" || event.key === "Enter") {
        event.preventDefault();
        $content.blur();
      }
    });

    $content.addEventListener("blur", (_event) => {
      if (formState.allowSubmit.value) {
        onSubmit();
      }
    });
  },
});
