getArguments = require './get-arguments'

construct = (c, args) ->
  class F
    constructor: -> c.apply @, args
  F.prototype = c.prototype
  return new F()

runFactory = (factory, args) ->
  factory.apply null, args

module.exports = class Container

  constructor: ->
    @factories = {}
    @instances = {}
    @constructors = {}

  factory: (name, func) ->
    throw new Error 'A factory must be a function' unless func instanceof Function
    @factories[name] = func

  value: (name, value) -> @instances[name] = value

  class: (name, constructor) ->
    throw new TypeError 'A constructor must be a function' unless constructor instanceof Function
    @constructors[name] = constructor

  get: (name) ->
    if @instances[name]?
      return @instances[name]
    else if @isRegistered name
      @_instantiate name
      return @instances[name]
    else
      throw new Error 'Could not find any module with name ' + name

  isRegistered: (name) -> @factories[name]? || @constructors[name]?

  _instantiate: (name) ->
    module = @_getFunctionAndType(name)
    func = module.function
    args = getArguments func

    dependencies = args.map (d) =>
      if @instances[d]? then  @instances[d] else @_instantiate d

    if module.type == 'factory'
      instance = runFactory func, dependencies
    else
      instance = construct func, dependencies

    @instances[name] = instance
    return instance

  _getFunctionAndType: (name) ->
    factory = @factories[name]
    constructor = @constructors[name]

    type: if factory? then 'factory' else 'class'
    function: factory || constructor
