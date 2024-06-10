import { FnMayThrow, Dictionary, List, WideFunction } from './types'

export type Factory = WideFunction<Instance>
export type ClassConstructor = WideFunction<Instance>
export type ImmediateValue = unknown
export type Instance = unknown

export type RegistrationName = string
export type RegistrationValue = Factory | ClassConstructor | ImmediateValue
export type RegistrationType = 'factory' | 'value' | 'class'

type Registrations = Record<string, Registration>

export interface Registration {
  value: RegistrationValue
  type: RegistrationType
}

export class Container {
  constructor (conf: ContainerConfig, parents?: unknown[]): void

  // || INTERNAL || //
  /** @private */
  _modules: ContainerConfig | ContainerConfig['modules']
  /** @private */
  _registrations: Registrations
  /** @private */
  _instances: Record<string, Instance>
  /** @private */
  _register(type: RegistrationType, name: RegistrationName, value: Instance): Registration
  /** @private */
  _instantiate(name: RegistrationName, parent: RegistrationName): FnMayThrow<Instance>
  /** @private */
  _instantiateWithDependencies(name: RegistrationName, value: RegistrationValue, type: Exclude<RegistrationType, 'value'>): FnMayThrow<Instance>
  /** @private */
  _registeredAt(name: RegistrationName): number | 'local'
  /** @private */
  _isInstantiated(name: RegistrationName): boolean

  // || CONTROL || //
  shutdown(): void
  loadAll(): void

  // || INSTANTIATE || //
  factory(name: RegistrationName, func: Factory): FnMayThrow<Registration>
  class(name: RegistrationName, constructor: ClassConstructor): FnMayThrow<Registration>
  value(name: RegistrationName, value: ImmediateValue): Registration
  spread(obj: Record<RegistrationName, ImmediateValue>): void

  // || QUERY || //
  getArguments(name: RegistrationName): string[]
  getRegistrations(): Registrations
  isRegistered(name: RegistrationName): boolean
  get(name: RegistrationName): FnMayThrow<Instance>
}

export interface ContainerConfig {
  modules?: unknown
}

export interface FromConfigOpts {
  config: unknown
  basePath: string
  opts: unknown
  parents: unknown
}

export declare function fromConfig (opts: FromConfigOpts): Container
