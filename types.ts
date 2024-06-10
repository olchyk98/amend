export type Dictionary<T = unknown, K extends string = string> = Record<K, T>
export type List<T = unknown> = T[]
export type FnMayThrow<T> = T | never
export type WideFunction<R = unknown, A = unknown> = (...args: A[]) => R
