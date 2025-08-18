import { Hook } from "phoenix_live_view";

const SELECTOR = {
  close: "[data-type='Dialog.close']",
} as const;

const ATTRS = {
  onCancel: "data-dialog-on-cancel",
} as const;

export default (): Hook => ({
  mounted() {
    const $dialog = this.el as HTMLDialogElement;
    const $close = $dialog.querySelector(SELECTOR.close) as HTMLButtonElement;

    $close.addEventListener("click", () => {
      $dialog.close();
    });

    $dialog.addEventListener("close", () => {
      const onCancel = $dialog.getAttribute(ATTRS.onCancel);
      if (onCancel != null) {
        this.liveSocket.execJS(this.el, onCancel);
      }
    });

    $dialog.showModal();
  },

  updated() {
    const $dialog = this.el as HTMLDialogElement;
    $dialog.showModal();
  },
});
