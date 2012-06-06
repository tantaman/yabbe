# "destroyed" event
# -----------------
# This is an event that will fire whenever an element is removed from the `DOM`.
# This is used to unbind from a `Model` when a `Binder`'s or `View`'s element if
# removed from the `DOM`.
if !$.event.special.destroyed
	$.event.special.destroyed =
    	remove: (o) ->
    		if o.handler
    			o.handler()

# Default values for the middleware options.
middlewareDefaults = 
	toView: {}
	toModel: {}

# Set up the Yabbe namespace
Yabbe = this.Yabbe = {}

# Yabbe.Binder
# ------------
Yabbe.Binder = class Binder
	# The `Binder` constructor takes a variety of options.
	# A brief summary of each is provided below
	#
	#    opts: {
	#
	#		model: A backbone model,
	#
	#		el: a $() element or regular dom element,
	#
	#		bindings: map of bindings.  Can be the verbose or 
	#									short hand version,
	#
	#		middleware: optional middleware functions {
	#			toView: Map of Middleware functions to apply before updating
	#						the view with a value from the model
	#			toModel: Map of Middleware functions to apply
	#				before updating the model with a value from the view
	#		}
	#    }
	#
	constructor: (opts) ->
		@model = opts.model
		@$el = if opts.el instanceof $ then opts.el else $(opts.el)
		@middleware = opts.middleware or {}
		_.defaults(@middleware, middlewareDefaults)
		@_readers = []

		# When $el is removed from the dom, unapply
		# our data bindings
		@$el.bind("destroyed", () =>
			@dispose()
		)

		@_bind(opts.bindings)

	# Unbind from the model.  This is called automatically when `el` is removed from the `DOM`
	# Use `$el.detach()` to removed `el` from the `DOM` without triggering
	# a call to `dispose`
	dispose: () ->
		@model.off(null, null, @)

	readAll: () ->
		for reader in @_readers
			if typeof reader is "function"
				reader()
			else
				reader.fn.call(null, @model, @model.get(reader.field))

	# Take the set of mappings and bind to the model
	_bind: (mapping) ->
		# mapping is generally a map of selectors to binding definitions
		for selector, binding of mapping
			# if the binding definition is an object then we are
			# using the long hand way to declare our bindings
			if typeof binding is "object"
				$target = @$el.find(selector)
				@_applyBinding($target, binding, {toView: @middleware.toView[selector]})

			# if we aren't using the long hand version then the key
			# contains the method to call and selector to apply
			else
				idx = selector.indexOf(" ")
				actualSelector = $.trim(selector.substring(idx))
				$target = @$el.find(actualSelector)
				bindingObj = 
					fn: selector.substring(0, idx)
					field: binding

				@_applyBinding($target, bindingObj, {toView: @middleware.toView[actualSelector]})

	_applyBinding: ($target, binding, middleware) ->
		field = binding.field
		# TODO: special case collections....
		if typeof @model[field] is "function"
			@_bindToComputedProperty($target, binding, middleware)
		else
			# TODO: we need to special case backbone collections
			# TODO: what if someone wants to bind to arbitrary events and not fields?
			# What about bindings in the other direction? view to model isntead of model to view
			# should we automatically assume bindings are bi-directional
			# when the view element is an input element?
			fn = (model, value) ->
				if middleware.toView?
					value = middleware.toView(value)
				callView($target, binding.fn, value)

			@model.on("change:" + field, fn)

			@_readers.push(field: field, fn: fn)

	_bindToComputedProperty: ($target, binding, middleware) ->
		dependencies = {}
		oldGet = @_replaceGet(dependencies)
		@model[binding.field]()
		@_restoreGet(oldGet)

		fn = () =>
			value = @model[binding.field]()
			if middleware.toView?
				value = middleware.toView(value)
			callView($target, binding.fn, value)

		@_readers.push(fn)

		for field,value of dependencies
			@model.on("change:" + field, fn)

	_replaceGet: (dependencies) ->
		oldGet = @model.get
		@model.get = (key) =>
			result = oldGet.apply(@model, arguments)
			dependencies[key] = true
			result

		oldGet

	_restoreGet: (oldGet) ->
		@model.get = oldGet



callView = ($target, fn, value) ->
	fnType = typeof fn
	if Array.isArray(fn)
		fnType = "array"
	switch fnType
		when "string"
			$target[fn](value)
		when "object"
			for key,fnData of fn
				comp = comparers[key]
				if (comp(value))
					$target[fnData[0]].apply($target, fnData.slice(1, fnData.length))
		else
			for fnName in fn
				$target[fnName](value)

comparers = 
	true: (val) -> val is true
	false: (val) -> val is false
	truthy: (val) -> val == true
	falsy: (val) -> val == false
	exists: (val) -> val?
	missing: (val) -> not val?

Backbone.YabbeView = Backbone.View.extend(
	initialize: () ->
		@_binder = new Yabbe.Binder(model: @model, el: @$el, bindings: @bindings, middleware: @middleware)
		@_binder.readAll()
)

Yabbe.View = Backbone.YabbeView

# Requirements:
# Should be able to use existing tempaltes as much as possible.  Writing new templates is annoying
# Should not require data-bind attributes in code
# Should be able to add "middleware" to intercept bound events...
# Should be similar to backbone "events:" hash

# mapping hash:
###
	"attribute selector": "fieldName"  (where attribute is some jquery func: text, val, css, addClass, removeClass, etc.)
	well what if we want one func on true and another on false.. that is a common use case...

	#alternative:

		"selector": 
			fn: "jQuery fn to apply"  (what about ender and so on?)
			field: "name of model field to observe"
			# optional funcs to apply with certain values
			fn_false:
			fn_missing:
			events: [list of events to bind from view back to model]???

		What about middleware?  Allow that to be passed in through the mapping variable?

	How should / could we handle computed properties?
	How do we know what properties a func will depend on?
		1. We can specify it in the mapping..
		2. We can use wizardry (error prone)
		3. We can run the function and see what "gets" it calls...
		  The gets that are called then obviously make up our computed property
			if the func has side effects then that is a non-starter
			add the stipulation that it can't had side effects?  It is a getter anyway...
###