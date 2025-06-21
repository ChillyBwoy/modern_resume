import { Hook } from "phoenix_live_view";

import { useFormState, createInputEvent, createSubmitEvent } from "../lib/form";

const SELECTOR = {
  content: "[data-type='InlineTextEditContent']",
  input: "[data-type='InlineTextEditInput']",
} as const;

export default (): Hook => ({
  mounted() {
    const $content = this.el.querySelector(SELECTOR.content) as HTMLElement;
    const $input = this.el.querySelector(SELECTOR.input) as HTMLInputElement;
    const $form = this.el.closest("form") as HTMLFormElement;

    const value = this.el.dataset.value ?? "";
    const multiline = this.el.dataset.multiline != null;

    const onSubmit = createSubmitEvent($form);
    const onInput = createInputEvent($input);

    const formState = useFormState($form);

    $content.addEventListener("keydown", (event) => {
      if (multiline && event.shiftKey) {
        return;
      } else if (event.key === "Escape" || event.key === "Enter") {
        event.preventDefault();
        $content.blur();
      }
    });

    $content.addEventListener("paste", (event) => {
      event.preventDefault();
      const text = event.clipboardData?.getData("text/plain") ?? "";
      document.execCommand("insertHTML", false, text);
    });

    $content.addEventListener("input", (_event) => {
      onInput($content.innerText.trim());
    });

    $content.addEventListener("blur", (_event) => {
      if (formState.allowSubmit.value) {
        onSubmit();
      }
    });
  },
});
