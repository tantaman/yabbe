// Basic sanity checks for prototyping until the real unit tests & dev start
$(function() {
	var ModelClass = Backbone.Model.extend({
		computed: function() {
			return this.get("weed") + this.get("snow")
		}
	});

	// ====== Short Hand binding method ======== //
	var model = new ModelClass({snow: "white"});
	new Yabbe.Binder({
		model: model,
		el: $("#shortHand"),
		bindings: {
			"text span": "weed",
			"addClass div": "computed",
			"text div": "computed"
		}
	});
	model.set("weed", "short");
	model.set("snow", "hand");


	// ======== Extend BinderView using short hand ========= //
	var bv = Yabbe.View.extend({
		bindings: {
			"text span": "weed",
			"addClass div": "computed",
			"text div": "computed"
		}
	});

	BinderViewModel = new ModelClass({snow: "white"});
	new bv({
		el: $("#BinderView"),
		model: BinderViewModel
	});

	BinderViewModel.set("weed", "whacker");


	// ====== Short Hand with middleware ======= //
	model = new ModelClass({snow: "green"});
	new Yabbe.Binder({
		model: model,
		el: $("#withMW"),
		bindings: {
			"text span": "weed",
			"html div": "computed"
		},

		middleware: {
			toView: {
				"span": function(val) {
					return val.toUpperCase();
				},

				"div": function(val) {
					return "<b style='color: green'>" + val + "</b>";
				}
			}
		}
	});

	model.set("weed", "middelwarez");

	window.mwModel = model;


	// ======= LongHand binding method ========== //
	model = new ModelClass({snow: "white"})
	new Yabbe.Binder({
		model: model,
		el: $("#longHand"),
		bindings: {
			"span": {
				fn: "text",
				field: "weed"
			},

			"div": {
				fn: ["text", "addClass"],
				field: "computed"
			},

			"h1": {
				fn: {
					false: ["removeClass", "active"],
					true: ["addClass", "active"]
				},
				field: "thinger"
			}
		}
	});

	model.set("weed", "long");
	model.set("snow", "hand");
	model.set("thinger", true);

	window.longHandModel = model;
});
