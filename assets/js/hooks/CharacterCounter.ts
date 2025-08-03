import { Hook } from "phoenix_live_view";

const SELECTOR = {
  input: "[data-type='CharacterCounter.input']",
  counter: "[data-type='CharacterCounter.counter']",
} as const;

const ATTRS = {
  maxLengthVal: "data-max-length",
} as const;

const CLASSES = {
  ok: "text-secondary",
  warning: "text-warning",
  danger: "text-danger",
} as const;

const THRESHOLD = [
  [90, CLASSES.danger],
  [75, CLASSES.warning],
  [-1, CLASSES.ok],
] as const;

const toggleClasses = (el: HTMLElement, value: number) => {
  for (const cl of Object.values(CLASSES)) {
    el.classList.remove(cl);
  }

  for (const [threshold, className] of THRESHOLD) {
    if (value >= threshold) {
      el.classList.add(className);
      break;
    }
  }
};

const updateCounter = (el: HTMLElement) => {
  const $input = el.querySelector(SELECTOR.input) as HTMLInputElement;
  const $counter = el.querySelector(SELECTOR.counter) as HTMLElement;
  if ($input == null || $counter == null) {
    return;
  }

  const maxLength = parseInt(el.getAttribute(ATTRS.maxLengthVal) || "0", 10);
  if (maxLength <= 0) {
    return;
  }

  const currentLength = $input.value.length;
  $counter.textContent = currentLength.toString();

  toggleClasses($counter, (currentLength / maxLength) * 100);
};

export default (): Hook => ({
  mounted() {
    updateCounter(this.el);

    const update = () => {
      updateCounter(this.el);
    };

    this.el.addEventListener("input", update);
    this.el.addEventListener("keyup", update);
    this.el.addEventListener("paste", () => {
      // Delay to allow paste content to be processed
      setTimeout(update, 100);
    });
  },

  updated() {
    updateCounter(this.el);
  },
});
