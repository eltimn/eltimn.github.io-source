+++
title = "JavaScript Apps With Lift: Build Tools"
date = "2013-04-06T14:59:45-05:00"
+++

Now that we know how to organize and write our JavaScript code, we need a way to build our single file for use in production. There are several ways you can do this.

### Scala Build Tool

Most build tools have plugins for this, whether you're using SBT, Maven, or Gradle. I'm an SBT user, so I've been using [sbt-closure](https://github.com/eltimn/sbt-closure) and [less-sbt](https://github.com/softprops/less-sbt). However, these are extremely slow, the SBT plugins, that is. I haven't used the other build tools. Also, it's not necessary to run google closure every time a change is made. This really only needs to be done once, when packaging for deployment.

### [sbt-resource-management](https://github.com/Shadowfiend/sbt-resource-management)

This is a sbt plugin along with a snippet to be used in your Lift app. It allows you to define bundles of files, which the snippet either loads indvidually or as a single file, depending on whether you're in development or production mode. The only problem I had with this was that I use Twitter Bootstrap's less source files and there isn't a way to specify a single file to process. It only has a directory setting. So it processes all of the less files instead of only the single file that I need processed.

### [Grunt](http://gruntjs.com/)

Grunt is a build tool written in JavaScript as a Node module. It requires Node and npm, but it's super fast at concatenating JavaScript files and compiling LESS sources. It's also pretty easy to learn how to us if you already know JavaScript.

The [Lift Extras example app](https://github.com/eltimn/lift-extras/tree/master/example) uses Grunt for building the JavaScript and CSS. In addition to concatenating JavaScript files and compiling LESS sources it has tasks that runs a `linter` on your JavaScript code via [JsHint](http://www.jshint.com/), runs your JavaScript tests via [Jasmine](http://pivotal.github.io/jasmine/), and minifies your JavaScript via [UglifyJs](http://lisperator.net/uglifyjs/). It also has a watch task that will "compile" your code when any files change. So it will run automatically when you save the file in your editor.

See the app's [Gruntfile.js](https://github.com/eltimn/lift-extras/blob/master/example/Gruntfile.js) for more details.

This is currently my preferred tool to use. The only problem I've run into is that I use SBT to generate a package.json file that is used by Grunt to create the files. Sometimes, the two can get out of sync.


You may also want to check out [Bower](http://twitter.github.io/bower/). It's a dependency manager for JavaScript and CSS.

<div data-lift="embed?what=/templates-hidden/parts/js-lift-series"></div>
