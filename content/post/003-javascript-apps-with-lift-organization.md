+++
title = "JavaScript Apps With Lift: Organization"
date = "2013-04-03T14:59:45-05:00"
+++

With the goal of putting as much of our JavaScript code in external files and combing them into a single file, there are several ways to organize your code. A lot of developers are moving towards using an [AMD](https://github.com/amdjs/amdjs-api/wiki/AMD) loader, in particular [RequireJS](http://requirejs.org/) for webapps. With this, each of your JavaScript files will basically list the files it depends on and they are loaded by the loader. So, only the files you need are loaded. That's only recommended for development, though. For production, all of the files are combined using an optimizer.

Another approach is to use a single global object to put all of your code into. This is to minimize polluting the global namespace. One problem with this approach is that you need to make sure you create the sub objects for each namespace. For example, if you had this:

    window.App = {
      utils: {},
      views: {}
    };

And now, if you want to add a namespace in views, you would need to add:

    window.App = {
      utils: {},
      views: {
        user: {}
      }
    };

One solution is to create a function that will create the namespace object if it's not already defined. I like to add this to the main App object. You can also pass in settings and run any initialization code in your App object. Here's a full example:

    (function(window) {
      window.App = (function() {
        "use strict";

        // the instance to return
        var inst = {};

        inst.init = function(settings) {
          inst.settings = settings;

          // run any global init code here
        };

        /**
          * A convenience function for parsing string namespaces and
          * automatically generating nested namespace objects.
          *
          * Example:
          * App.namespace('modules.module2');
          *
          */
        inst.namespace = function(ns_string) {
          var parts = ns_string.split('.'),
              parent = inst,
              pl;

          pl = parts.length;
          for (var i = 0; i < pl; i++) {
            // create a property if it doesnt exist
            if (typeof parent[parts[i]] === 'undefined') {
              parent[parts[i]] = {};
            }
            parent = parent[parts[i]];
          }
          return parent;
        };

        return inst;
      }());
    })(this);

Now, in your external files you can just call this function to ensure the namespace exists and your files won't need to be loaded in a specific order, except, of course, the App.js file must be loaded first.

    App.namespace("views.notice");
    App.views.notice.FormsTestAjax = (function(ko) {
      "use strict";

      return {
        init: function() {},
        anObservable: ko.observable("hola")
      };
    })(ko);

For more information on namespacing, see:

* [Essential JavaScript Namespacing](http://addyosmani.com/blog/essential-js-namespacing/)
* [Development Using Namespaces](http://thanpol.as/javascript/development-using-namespaces/)

Now that we have a place to put our JavaScript code, I'll discuss ways to actually write code. In general, I use a single JavaScript file per Lift snippet. These go in the `views` namespace. I also put some utilities in the `utils` namespace that are used by view classes.

There are two different ways you can write your code; as a [module](http://addyosmani.com/resources/essentialjsdesignpatterns/book/#revealingmodulepatternjavascript), or as a "class". I use quotes around class because, technically, JavaScript doesn't support classes. But using the `new` keyword essentially creates an instance of a class.

I think of a module as more of a singleton object, so I mostly us it for utility functions. With modules, it's also more difficult to reuse code. On the other hand, classes provide opportunities for using [mixins](http://javascriptweblog.wordpress.com/2011/05/31/a-fresh-look-at-javascript-mixins/).

The [Lift Extras module](https://github.com/eltimn/lift-extras) has an example of each. First, the module version:

[KnockoutExampleMod.js](https://github.com/eltimn/lift-extras/blob/master/example/src/main/javascript/views/knockout/KnockoutExampleMod.js)

    App.namespace("views.knockout");
    App.views.knockout.KnockoutExampleMod = (function($, ko) {
      "use strict";

      // private stuff
      var saveFunc = function() {};

      // the instance to return
      var inst = {};

      inst.init = function(_saveFunc, _sendSuccess) {
        saveFunc = _saveFunc;
        inst.sendSuccess = _sendSuccess;
      };

      inst.textInput = ko.observable("");

      inst.submitForm = function() {
        var ret = { textInput: inst.textInput() };
        // call the passed in save function with the form data as an argument.
        saveFunc(ret);
      };

      inst.sendSuccess = function() {};

      inst.showWarning = function() {
        // sends a notice to the client
        $(document).trigger("add-alerts", {message: "This is a warning!", priority: "warning"});
      };

      return inst;
    }(jQuery, ko));

This is then called like this:

    App.views.knockout.KnockoutExampleMod.init(...);
    App.views.knockout.KnockoutExampleMod.showWarning();

The class version looks like this:

[KnockoutExampleCls.js](https://github.com/eltimn/lift-extras/blob/master/example/src/main/javascript/views/knockout/KnockoutExampleCls.js)

    App.namespace("views.knockout");
    App.views.knockout.KnockoutExampleCls = function(saveFunc, sendSuccess) {
      "use strict";

      var self = this;

      self.textInput = ko.observable("");

      self.submitForm = function() {
        var ret = { textInput: self.textInput() };
        // call the passed in save function with the form data as an argument.
        saveFunc(ret);
      };

      self.sendSuccess = sendSuccess;

      self.showWarning = function() {
        // sends a notice to the client
        $(document).trigger("add-alerts", {message: "<em>This is a warning!</em>", priority: "warning"});
      };
    };

Which is called like this:

    window.koExample = new App.views.knockout.KnockoutExampleMod(...);
    window.koExample.showWarning();

One drawback is you need to specify a global variable to attach the instance too.

Other resources:

* [How we Learned to Stop Worrying and Love JavaScript](https://speakerdeck.com/anguscroll/how-we-learned-to-stop-worrying-and-love-javascript)

<div data-lift="embed?what=/templates-hidden/parts/js-lift-series"></div>
