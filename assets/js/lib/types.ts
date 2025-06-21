export type JSActionData<T extends string, D = unknown> = {
  event: T;
  target?: number;
  value?: D;
};

export type JSAction<T extends string, D = unknown> = [
  "push",
  JSActionData<T, D>
];
