+++
title = "JavaScript Apps With Lift: JsClass"
date = "2013-04-05T14:59:45-05:00"
+++

The [Lift Extras](https://github.com/eltimn/lift-extras) module adds some convenience classes to help with interfacing between your Scala snippet code and your JavaScript code.

In my [last post](http://www.eltimn.com/blog/004-javascript-apps-with-lift-callback-functions) the code used to initialize the JavaScript code from within the snippet looked like this (minus the knockout binding call):

    val onload: JsCmd =
      SetExp(
        JsVar("window.koExample"),
        JsExtras.CallNew(
          "App.views.knockout.KnockoutExampleCls",
          JsExtras.AjaxCallbackAnonFunc(sendSucces),
          JsExtras.JsonCallbackAnonFunc(saveForm),
        )
      )
    )

Elsewhere, there's a call to a function on the JavaScript class:

    Call("window.koExample.textInput", Str(""))

There are a couple of things that bother me about this. `window.koExample` is referenced in multiple places. The `SetExp` call is similar for all JavaScript classes.

[JsClass and KoClass](https://github.com/eltimn/lift-extras/blob/master/library/src/main/scala/net/liftmodules/extras/JsClass.scala) aim to help with those things. They provide a way to encapsulate some of the details of your JavaScript code and functions for calling functions on your JavaScript code. Using JsClass would change the above code to:

    val jsClass = JsClass("App.views.knockout.KnockoutExampleCls", "window.koExample")

    val onload: JsCmd = jsClass.init(
      JsExtras.AjaxCallbackAnonFunc(sendSucces),
      JsExtras.JsonCallbackAnonFunc(saveForm)
    )

And, where you need to call a function on your JavaScript class use:

    jsClass.call("textInput", Str(""))

There is a also a [knockout.js](http://knockoutjs.com/) version, KoClass, that adds the ko binding call to the init function. The above example would look like this:

    val koClass = KoClass("App.views.knockout.KnockoutExampleCls", "window.koExample", "knockout-example-cls")

    val onload: JsCmd = koClass.init(
      JsExtras.AjaxCallbackAnonFunc(sendSucces),
      JsExtras.JsonCallbackAnonFunc(saveForm)
    )

Similar classes also exist for the module versions of the above: [JsModule and KoModule](https://github.com/eltimn/lift-extras/blob/master/library/src/main/scala/net/liftmodules/extras/JsModule.scala)

<div data-lift="embed?what=/templates-hidden/parts/js-lift-series"></div>
