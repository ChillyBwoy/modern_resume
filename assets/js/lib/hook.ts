export interface HookActionData<T extends string, D = unknown> {
  event: T;
  target?: number;
  value?: D;
}

export type HookAction<T extends string, D = unknown> = [
  "push",
  HookActionData<T, D>
];

export function extractHookAction<T extends string, D = unknown>(
  el: HTMLElement,
  attribute: string
): HookActionData<T, D> | null {
  const data = el.dataset[attribute];
  if (data == null) {
    return null;
  }

  try {
    const sortAction: HookAction<T, D>[] = JSON.parse(data);
    const [_, { target, event, value }] = sortAction[0];
    return { event, target, value };
  } catch {
    return null;
  }
}
