declare module "phoenix_live_reload" {}

declare global {
  interface WindowEventMap {
    "phx:live_reload:attached": CustomEvent<{ detail: number }>;
  }

  interface Window {
    readonly liveReloader: any;
  }
}
