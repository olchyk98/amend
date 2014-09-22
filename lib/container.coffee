getArguments = require './get-arguments'

construct = (c, args) ->
  class F
    constructor: -> c.apply @, args
  F.prototype = c.prototype
  return new F()

runFactory = (factory, args) ->
  factory.apply null, args

module.exports = class Container

  constructor: (conf = {}) ->
    @_modules = conf.modules || {}
    @_registrations = {}
    @_instances = {}

  factory: (name, func) ->
    throw new Error 'A factory must be a function' unless func instanceof Function
    @_register 'factory', name, func

  value: (name, value) -> @_register 'value', name, value

  class: (name, constructor) ->
    throw new TypeError 'A constructor must be a function' unless constructor instanceof Function
    @_register 'class', name, constructor

  get: (name) ->
    throw new Error 'Could not find any module with name ' + name unless @isRegistered name
    @_instantiate name unless @_instances[name]?
    return @_instances[name]

  isRegistered: (name) -> @_registrations[name]?

  getArguments: (name) ->
    if @_modules[name]?
      @_modules[name]
    else
      getArguments @_registrations[name].value

  loadAll: ->
    Object.keys(@_registrations).forEach (name) =>
      @_instantiate name unless @_instances[name]?

  _register: (type, name, value) -> @_registrations[name] = value: value, type: type

  _instantiate: (name) ->
    module = @_registrations[name]
    type = module.type
    value = module.value
    instance = if type == 'value' then value else @_instantiateWithDependencies name, value, type
    @_instances[name] = instance
    return instance

  _instantiateWithDependencies: (name, value, type) ->
    args = @getArguments name

    dependencies = args.map (d) =>
      if @_instances[d]? then @_instances[d] else @_instantiate d

    return runFactory value, dependencies if type == 'factory'
    return construct value, dependencies if type == 'class'
