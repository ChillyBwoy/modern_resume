import { Hook } from "phoenix_live_view";

export default (): Hook => ({
  updated() {
    const children = Array.from(this.el.children) as HTMLElement[];
    const active = children.find((el) => el.dataset.active != null);

    if (active != null) {
      active.scrollIntoView({
        behavior: "smooth",
        block: "center",
        inline: "center",
      });
    }
  },
});
