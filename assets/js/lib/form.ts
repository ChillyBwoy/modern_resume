import { ref, watch } from "@vue/reactivity";
import { ViewHookInterface } from "phoenix_live_view";
import type { JSAction, JSActionData } from "./types";

const FORM_CLASS = {
  isLoading: "phx-submit-loading",
} as const;

export function useFormState(form: HTMLFormElement) {
  const isLoading = ref(false);
  const isFocused = ref(false);
  const allowSubmit = ref(false);

  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (
        mutation.type === "attributes" &&
        mutation.attributeName === "class"
      ) {
        const form = mutation.target as HTMLFormElement;
        isLoading.value = form.classList.contains(FORM_CLASS.isLoading);
      }
    }
  });

  observer.observe(form, {
    attributes: true,
    attributeFilter: ["class"],
  });

  form.addEventListener("focusin", () => {
    isFocused.value = true;
  });

  form.addEventListener("focusout", () => {
    isFocused.value = false;
  });

  watch([isFocused, isLoading], ([newIsFocused, newIsLoading]) => {
    allowSubmit.value = newIsFocused && !newIsLoading;
  });

  return { allowSubmit };
}

function getFormSubmitAction<T extends string>(
  form: HTMLFormElement
): JSActionData<T> | JSActionData<T>[] | null {
  const data = form.getAttribute("phx-submit");
  if (data == null) {
    return null;
  }

  try {
    const rawAction = JSON.parse(data) as JSAction<T>[];
    return rawAction.map((action) => action[1]);
  } catch {
    return {
      event: data as T,
    };
  }
}

function dispatch<T extends string>(
  action: JSActionData<T>,
  context: ViewHookInterface
) {
  if (action.target != null) {
    context.pushEventTo(action.target, action.event, action.value ?? {});
  } else {
    context.pushEvent(action.event, action.value);
  }
}

export function createSubmitAction(form: HTMLFormElement) {
  const action = getFormSubmitAction(form);
  return (context: ViewHookInterface) => {
    if (action == null) {
      return;
    }

    if (Array.isArray(action)) {
      action.forEach((act) => dispatch(act, context));
    } else {
      dispatch(action, context);
    }
  };
}

export function createSubmitEvent(form: HTMLFormElement) {
  return () => {
    const event = new Event("submit", { bubbles: true, cancelable: true });
    form.dispatchEvent(event);
  };
}

export function createInputEvent(input: HTMLInputElement) {
  return (value: string) => {
    input.value = value;
    input.dispatchEvent(new Event("input", { bubbles: true }));
  };
}
