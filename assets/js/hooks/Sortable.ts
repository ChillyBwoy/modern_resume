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
        const orderedIds: string[] = [];

        for (const el of this.el.children) {
          const dataset = (el as HTMLElement).dataset;
          if (dataset.sortable != null && dataset.id != null) {
            orderedIds.push(dataset.id);
          }
        }

        this.pushEvent(sortEvent, orderedIds);
      },
    });
  },
});
