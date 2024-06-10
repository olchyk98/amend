ModuleNotFound = require './ModuleNotFound'
getArguments = require './get-arguments'

construct = (c, args) ->
  class F
    constructor: -> c.apply @, args
  F.prototype = c.prototype
  return new F()

runFactory = (factory, args) ->
  factory.apply null, args

throwNotFound = (name, parent) ->
  throw new ModuleNotFound name, parent

module.exports = class Container
  # DONE
  constructor: (conf = {}, @_parents = []) ->
    @_modules = conf.modules || conf
    @_registrations = {}
    @_instances = {}

  # DONE
  factory: (name, func) ->
    throw new Error 'A factory must be a function' unless func instanceof Function
    @_register 'factory', name, func

  # DONE
  value: (name, value) -> @_register 'value', name, value

  # DONE
  class: (name, constructor) ->
    throw new TypeError 'A constructor must be a function' unless constructor instanceof Function
    @_register 'class', name, constructor

  # DONE
  spread: (obj) -> @value(k, v) for k, v of obj

  # DONE
  get: (name) ->
    throwNotFound name unless @isRegistered name
    registeredAt = @_registeredAt(name)
    if registeredAt == 'local'
      @_instantiate name unless @_isInstantiated(name)
      return @_instances[name]
    else
      return @_parents[registeredAt].get(name)

  # DONE
  _isInstantiated: (name) -> Object.keys(@_instances).indexOf(name) != -1

  # DONE
  _registeredAt: (name) ->
    if @_registrations[name]?
      return 'local'
    else
      for p, i in @_parents
        if p._registeredAt(name)?
          parentIndex = i
      return parentIndex

  # DONE
  isRegistered: (name) -> @_registeredAt(name) != undefined

  # DONE
  getRegistrations: ->
    if @_parents.length == 0
      return @_registrations

    all = (p.getRegistrations() for p in @_parents)
    all.push @_registrations
    all.reduce (acc, item) ->
      Object.keys(item).forEach (key) -> acc[key] = item[key]
      return acc
    , {}

  # DONE
  getArguments: (name) ->
    if @_modules[name]?
      @_modules[name]
    else
      getArguments @_registrations[name].value

  # DONE
  loadAll: ->
    p.loadAll() for p in @_parents
    Object.keys(@_registrations).forEach (name) =>
      @_instantiate name unless @_isInstantiated(name)

  # DONE
  shutdown: ->
    Object.keys(@_instances).forEach (key) =>
      @_instances[key]?.__amendShutdown?()
    p.shutdown() for p in @_parents

  # DONE
  _register: (type, name, value) -> @_registrations[name] = value: value, type: type

  # DONE
  _instantiate: (name, parent) ->
    module = @_registrations[name]
    throwNotFound name, parent unless module?
    type = module.type
    value = module.value
    instance = if type == 'value' then value else @_instantiateWithDependencies name, value, type
    @_instances[name] = instance
    return instance

  # DONE
  _instantiateWithDependencies: (name, value, type) ->
    args = @getArguments name

    dependencies = args.map (depName) =>
      registeredAt = @_registeredAt(depName)
      if registeredAt == 'local'
        if @_isInstantiated(depName) then @_instances[depName] else @_instantiate depName, name
      else if registeredAt?
        @_parents[registeredAt].get(depName)
      else
        throwNotFound depName, name

    return runFactory value, dependencies if type == 'factory'
    return construct value, dependencies if type == 'class'
