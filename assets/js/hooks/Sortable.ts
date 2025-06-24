import { Hook } from "phoenix_live_view";
import Sortable from "sortablejs";
import { JSAction } from "../lib/types";

const SELECTOR = {
  handle: "[data-type='sort-handle']",
} as const;

const CLASSES = {
  drag: "sortable-drag",
} as const;

export default (): Hook => ({
  mounted() {
    const sortEvent = this.el.dataset.sortAction;
    if (sortEvent == null) {
      return;
    }

    new Sortable(this.el, {
      animation: 150,
      dragClass: CLASSES.drag,
      handle: SELECTOR.handle,
      onEnd: () => {
        const data = Array.from(this.el.children).reduce<number[]>(
          (acc, el) => {
            const index = (el as HTMLElement).dataset.index;
            if (index == null) {
              return acc;
            }
            acc.push(parseInt(index, 10));
            return acc;
          },
          []
        );
        this.pushEvent(sortEvent, data);
      },
    });
  },
});
