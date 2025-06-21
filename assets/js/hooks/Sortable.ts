import { Hook } from "phoenix_live_view";
import Sortable from "sortablejs";
import { JSAction } from "../lib/types";

const SELECTOR = {
  handle: "[data-type='sort-handle']",
} as const;

const CLASSES = {
  drag: "sortable-drag",
} as const;

function extractSortAction(el: HTMLElement) {
  if (el.dataset.sortAction == null) {
    return null;
  }

  try {
    const sortAction: JSAction<"sort">[] = JSON.parse(el.dataset.sortAction);
    const [_, { target, event }] = sortAction[0];

    return { target, event };
  } catch {
    return null;
  }
}

export default (): Hook => ({
  mounted() {
    const sortAction = extractSortAction(this.el);
    if (sortAction == null) {
      return;
    }

    new Sortable(this.el, {
      animation: 150,
      dragClass: CLASSES.drag,
      handle: SELECTOR.handle,
      onEnd: () => {
        const data = Array.from(this.el.children).map(
          (el) => (el as HTMLElement).dataset.id
        );
        this.pushEventTo(sortAction.target, sortAction.event, data);
      },
    });
  },
});
