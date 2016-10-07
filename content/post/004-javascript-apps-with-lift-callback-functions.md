+++
title = "JavaScript Apps With Lift: Callback Functions"
date = "2013-04-04T14:59:45-05:00"
+++

One of my favorite features of Lift is the ability to call functions on the server via ajax. This is mostly achieved using built in features. However, I also like to be able to call these functions via JavaScript directly. So, I created some functions to help with this.

First, let's take a look at [AjaxCallbackAnonFunc][JsExtras]:

     object AjaxCallbackAnonFunc {
        def apply(callback: () => JsCmd): AnonFunc = {
          val funcCmd = S.fmapFunc(S.SFuncHolder(s => callback()))(name =>
            SHtml.makeAjaxCall(JsRaw("'" + name + "=true'"))
          )
          AnonFunc(funcCmd)
        }
      }

This creates an anonymous JavaScript function that calls the callback function via Ajax and executes the return JsCmd on the client.

There is also [JsonCallbackAnonFunc][JsExtras]:

    object JsonCallbackAnonFunc {
      def apply(callback: JValue => JsCmd): AnonFunc = {
        val funcCmd = S.fmapFunc(S.SFuncHolder(s => LiftExtras.parseJsonFunc.vend(s, callback)))(name =>
          SHtml.makeAjaxCall(JsRaw("'" + name + "=' + encodeURIComponent(JSON.stringify(data))"))
        )
        AnonFunc("data", funcCmd)
      }
    }

This creates an anonymous JavaScript function that takes JSON data as a parameter and sends it to a callback function via Ajax and executes the return JsCmd on the client.

Here's an example snippet that uses both:

    object KnockoutExampleCls extends SnippetHelper with Loggable {

      def render(in: NodeSeq): NodeSeq = {
        /**
          * A test function that sends a success notice back to the client.
          */
        def sendSuccess(): JsCmd = LiftNotice.success(<em>You have success</em>).asJsCmd

        /**
          * The function to call when submitting the form.
          */
        def saveForm(json: JValue): JsCmd = {
          for {
            msg <- tryo((json \ "textInput").extract[String])
          } yield {
            val logMsg = "textInput from client: "+msg
            logger.info(logMsg)
            S.notice(logMsg)
            Call("window.koExample.textInput", Str("")): JsCmd
          }
        }

        /**
          * Initialize the knockout view model, passing it the anonymous functions
          */
        val onload: JsCmd =
          SetExp(
            JsVar("window.koExample"),
            JsExtras.CallNew(
              "App.views.knockout.KnockoutExampleCls",
              JsExtras.AjaxCallbackAnonFunc(sendSucces),
              JsExtras.JsonCallbackAnonFunc(saveForm),
            )
          ) &
          Call("ko.applyBindings", JsVar("window.koExample"), Call("document.getElementById", "knockout-example-cls"))
        )

        S.appendJs(onload)

        in
      }
    }

Which outputs the following JavaScript:

    <script type="text/javascript">
    // <![CDATA[
    jQuery(document).ready(function() {
      window.koExample = new App.views.knockout.KnockoutExampleCls(
        function() {
          liftAjax.lift_ajaxHandler('F301359182285033KTB=true', null, null, null);
        },
        function(data) {
          liftAjax.lift_ajaxHandler('F301359182286FERFGB=' + encodeURIComponent(JSON.stringify(data)), null, null, null);
        }
      );
      ko.applyBindings(window.koExample, document.getElementById("knockout-example-cls"));
    // ]]>
    </script>

The JavaScript view model class is:

    App.namespace("views.knockout");
    App.views.knockout.KnockoutExampleCls = function(sendSuccess, saveFunc) {
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

Notice how the functions are passed into the JavaScript code as parameters to the view model class. You now have the ability to call either of these functions in your JavaScript code.

I like this technique because all of your code is in one place and you can close over any data you may need in the snippet. It may not be as secure as some of Lift's built in stuff, but it's still more secure and faster and easier to write than calling APIs directly. However, if you need to provide a public API anyway it may make sense to use that.

[JsExtras]: https://github.com/eltimn/lift-extras/blob/master/library/src/main/scala/net/liftmodules/extras/JsExtras.scala "JsExtras"

<div data-lift="embed?what=/templates-hidden/parts/js-lift-series"></div>
