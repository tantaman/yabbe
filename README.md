Yet Another Backbone Binding Extension (Yabbe)
====

So why add to the already growing number of libraries to do data binding?  

* Existing libraries didn't seem to fit `Backbone` very well.
* Other libraries often try to perform too much magic which just ended up making them unusable for certain cases.  `Yabbe` forgoes much of the magic for just a little more typing.
* Other libraries seem to lack of actual support for computed properties.

This library is intended to provide a style of data binding that will be immediately familiar to users of `Backbone`.  `Yabbe` will also not stand in your way if you don't want to use data binding for certain elements.

###Something simple to wet your appetite###
```javascript
var ExampleView = Yabbe.View.extend({
  	model: ex1model,
		el: $("#ex1"),
		// the bindings property is very similar to the events hash!
		bindings: {
			"val input": "title",
			"text div > a": "status",
		}
	});
```

##Check out the full examples!##
http://tantaman.github.com/yabbe/examples/YabbeViewExamples.html

###Notes###
Yabbe is still in early development and the API is subject to change.  
Binding is currently uni-directional (from models to views). Bi-directional binding will be added in a future version.

Yabbe has only been tested with `jQuery`.

Test cases are still being written to flex and verify all of the different pieces of the code.

###TODO###
* Bi-directional binding
* Binding for collections
* Clean up overlaoded method handling code
* Test with `zepto` and other backbone libs
