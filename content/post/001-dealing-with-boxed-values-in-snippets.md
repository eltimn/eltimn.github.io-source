+++
title = "Dealing with Boxed values in Lift snippets"
date = "2013-03-26T14:59:45-05:00"
+++

This post will demonstrate how to handle Box(ed) values in Lift snippets using for comprehensions. This is what a first attempt might look like:

    object MySnippet {
      object SomeRequestVar extends RequestVar[Box[String]](Full("nothing"))
      def render =
        for {
          myVar <- SomeRequestVar.is ?~ "MyVar is not defined"
          user <- User.currentUser ?~ "You must be logged in"
        } yield ({
          "#name" #> user.name.is
        }) match {
          case Full(csssel) => csssel
          case Failure(msg, _, _) => "*" #> <div class="error">{msg}</div>
          case Empty => "*" #> <div class="error">Empty</div>
        }
      }
    }

That's rather verbose and the last part that does the matching can be reused in all of your snippets. So, we can add an implicit conversion that will do that part for us.

    trait SnippetHelper {

      def errorDiv(msg: String) = <div class="error">{msg}</div>

      implicit protected def boxCssSelToCssSel(in: Box[CssSel]): CssSel = in match {
        case Full(csssel) => csssel
        case Failure(msg, _, _) => "*" #> errorDiv(msg)
        case Empty => "*" #> errorDiv("Unknown error")
      }
    }

The implicit conversion allows us to write our snippets like this:

    object MySnippet extends SnippetHelper {
      object SomeRequestVar extends RequestVar[Box[String]](Full("nothing"))
      def render =
        for {
          myVar <- SomeRequestVar.is ?~ "MyVar is not defined"
          user <- User.currentUser ?~ "You must be logged in"
        } yield ({
          "#name" #> user.name.is
        }): CssSel
      }
    }

Note that the Scala compiler needs a little help so we must specify the type.

That's much better, but sometimes we need to use the same Box(ed) values in multiple render functions in the same snippet. This can be helped by a trick I learned from [Tim Perrett](https://github.com/timperrett/lift-shiro/blob/master/library/src/main/scala/shiro/snippet/snippets.scala#L12 "lift-shiro").

In your snippet you can do the following:

    object MySnippet extends SnippetHelper {
      object SomeRequestVar extends RequestVar[Box[String]](Full("nothing"))
      private def serve(html: NodeSeq)(snip: (User, String) => CssSel): NodeSeq =
        (for {
          u <- user ?~ "User not found"
          myVar <- SomeRequestVar.is ?~ "MyVar is not defined"
        } yield {
          snip(u, myVar)(html)
        }): NodeSeq

      def renderName(html: NodeSeq): NodeSeq = serve(html) { (user, myVar) =>
        "#name" #> user.name.is
      }

      def renderMyVar(html: NodeSeq): NodeSeq = serve(html) { (user, myVar) =>
        "#myvar" #> myVar
      }
    }

That encapsulates the for comprehension into the serve function, so your render functions are just the CSS selector transforms.

The [Lift Extras](https://github.com/eltimn/lift-extras) module includes a SnippetHelper class and other code to handle the HTML output.
