export interface HookActionData<T extends string, D = unknown> {
  event: T;
  target: number | null;
  value: D | null;
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
    const action = sortAction[0];
    if (action == null) {
      return null;
    }
    const [_, { event, target, value }] = action;
    return { event, target, value };
  } catch {
    return null;
  }
}
