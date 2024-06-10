import { Any, FnMayThrow, Dictionary, List, WideFunction } from './types'

export type Factory = WideFunction<Instance>

export type ClassConstructor = WideFunction<Instance>

export type ImmediateValue = Any

export type Instance = Any

export type RegistrationName = string

export type RegistrationValue = Factory | ClassConstructor | ImmediateValue

export type RegistrationType = 'factory' | 'value' | 'class'

export type Registrations = Record<string, Registration>

export type Instances = Record<string, Instance>

export type Arguments = string[]

export type Path = string

// TODO: Is this common.json??
export type Modules = Record<string, Arguments>

export interface Registration {
  value: RegistrationValue
  type: RegistrationType
}

export class Container {
  constructor (conf: ContainerConfig, parents?: Container[]): void

  // || INTERNAL || //
  /** @private */
  _modules: Modules
  /** @private */
  _registrations: Registrations
  /** @private */
  _instances: Instances
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
  modules?: Modules
  parents?: Container[]
}

export interface AmendConstructorBaseOpts {
  clearCache?: boolean
  config: ContainerConfig
}

export interface FromConfigOpts extends AmendConstructorBaseOpts {
  basePath: string
  opts: ContainerConfig
}

export interface LoadNodeConfigOpts {
  baseDir: string
  annotations: Modules
}

export interface ConfigPathSpec {
  key: string
  path: string
  registeredPath: string
  isLocal: boolean
  module: Arguments
}

export declare function fromConfig (opts: FromConfigOpts): Container
export declare function loadNodeConfig (opts: LoadNodeConfigOpts): Container
export declare function getConfigPaths (base: string, conf: ContainerConfig, childCallers?: string[]): ConfigPathSpec[]
export declare function evaluateType (conf: Modules | string, instance: RegistrationValue): RegistrationType
