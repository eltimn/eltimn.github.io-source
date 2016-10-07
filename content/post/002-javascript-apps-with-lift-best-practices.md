+++
title = "JavaScript Apps With Lift: Best Practices"
date = "2013-04-02T14:59:45-05:00"
+++

In this post I will discuss best practices for serving assets within the context of a Lift app. [Google][1] and [Yahoo][2] have both published extensive material on this, so I won't go over all of the details. I will just concentrate on the things directly related to developing webapps with Lift.

#### Minimize HTTP Requests

In general you should combine all of your JavaScript files into a single file. For landing pages there may be other things to consider.

By default, Lift loads a couple of files dynamically.

_liftAjax.js_: You can turn this off and load it statically. Firstly, load your site and save the file, then in Boot.scala add the following:

    LiftRules.autoIncludeAjaxCalc.default.set(() => (session: LiftSession) => false)

If you ever make changes to the settings that are used to create the file, just re-save the file. See [ScriptRenderer.scala](https://github.com/lift/framework/blob/master/web/webkit/src/main/scala/net/liftweb/http/js/ScriptRenderer.scala) for more details.

_cometAjax.js_: This file inserts the user's session id, so it must be loaded dynamically.

#### Make JavaScript and CSS External

Put JavaScript code in external files instead of inlining. Lift inserts several inline `script` tags related to Ajax and Comet requests. These are necessary and can't be avoided. There also some functions in SHtml and some of the built-in snippets that produce inline `script` tags, use these judiciosuly.

For your own code, use `S.appendJs` whenever you can for any dynamic JavaScript code you need to send to the browser.

#### Stylesheets at the Top and Scripts at the Bottom

CSS in the `header` section. JavaScript just before the closing `body` tag. With Lift, you should put your JavaScript after your content in the default.html file. Here's an example:

    <!DOCTYPE html>
    <html lang="en">
      <head>
        ...
        <!-- css -->
        <link href="/assets/styles.css" rel="stylesheet">
      </head>
      <body>
        <div id="content" class="container"></div>
        <!-- javascript -->
        <script src="/assets/scripts.js"></script>
      </body>
    </html>

### Use Caching or a CDN

If you can afford a CDN, that's the best way to serve your assets. If not, you should follow these rules:

* Set the expires header to between one month and a year. The intent is to have your users only ever load it one time. This means you will need to rename your file every time you launch a new version.
* Do not use a query string on the asset URL. Some proxies will not cache assets with a query string on the URL.
* Set a `Cache-Control: public` header so proxies will cache the assets and share them among users.
* Serve GZIP versions to browsers that accept them.

Here is an example nginx config:

    server {
      listen 80;
      server_name www.example.com;
      access_log  /var/log/nginx/example.access.log;
      error_page 502 =503 /maint.html;

      location / {
        proxy_pass          http://127.0.0.1:8080/;
        proxy_set_header    X-Real-IP  $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    Host $http_host;
        proxy_read_timeout  700;
      }

      location ~ ^/(css|js|img)/  {
        root /var/www/example;
        expires 6M;
        add_header Cache-Control public;
      }

      location = /maint.html {
        root /var/www/example;
      }
    }

With this config, it's required to copy the assets to the /var/www/example directory.

<div data-lift="embed?what=/templates-hidden/parts/js-lift-series"></div>

[1]: https://developers.google.com/speed/docs/best-practices/rules_intro "Google"
[2]: http://developer.yahoo.com/performance/rules.html "Yahoo"
