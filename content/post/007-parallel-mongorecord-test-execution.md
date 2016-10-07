+++
title = "Parallel MongoRecord test execution with ScalaTest"
date = "2013-06-08T14:59:45-05:00"
+++

A few weeks ago, I finally figured out a way to enable parallel test execution of Lift MongoRecords using ScalaTest. The problem is when you call `MongoDB.defineDb` the entry is added to a Map with the MongoIdentifier as the key. So, you can't add more than one entry for the same MongoIdentifer, which means you can't use a different database for testing without doing them one at a time.

The solution is rather simple and involves Lift's [Dependency Injection mechanism](http://simply.liftweb.net/index-8.2.html#toc-Section-8.2). It allows us to use a different MongoIdentifier for each test suite.

First we need to define an injectable MongoIdentifier to add to our model's MongoMetaRecord. I put this in a MongoConfig object:

    package code
    package config

    import net.liftweb._
    import http.Factory
    import mongodb._

    object MongoConfig extends Factory {

      val identifier = new FactoryMaker[MongoIdentifier](DefaultMongoIdentifier) {}

      ...

    }

Next we need to override `def mongoIdentifier` in our MongoMetaRecord objects. I create a custom MongoMetaRecord trait where I do this and mix that into my models instead of MongoMetaRecord:

    package code
    package lib

    import code.config.MongoConfig

    import net.liftweb._
    import mongodb.record._

    /**
      * A custom MongoMetaRecord that adds an injectable MongoIdentifier.
      */
    trait MyMetaRecord[A <: MongoRecord[A]] extends MongoMetaRecord[A] {
      this: A =>

      override def mongoIdentifier = MongoConfig.identifier.vend
    }

Here's an example model that uses the above trait:

    package code
    package model

    import code.lib.MyMetaRecord

    import scala.xml._

    import net.liftweb._
    import common._
    import mongodb.record._
    import record.field._

    class Company private () extends MongoRecord[Company] with ObjectIdPk[Company] {
      def meta = Company

      object name extends StringField(this, 256) {
        override def displayName = "Name"

        override def validations =
          valMinLen(3, "Must be at least 3 characters") _ ::
          valMaxLen(256, "Must be 256 characters or less") _ ::
          super.validations
      }
    }

    object Company extends Company with MyMetaRecord[Company] {
      import mongodb.BsonDSL._

      override def collectionName = "main.companies"

      ensureIndex((name.name -> 1), true)
    }

Now, you can use the Mongo Suite's defined in [MongoTestKit.scala](https://github.com/eltimn/lift-mongo.g8/blob/master/src/main/g8/src/test/scala/%24package%24/MongoTestKit.scala) to create some traits to use with your tests:

    package code

    import config.MongoConfig

    import org.scalatest._
    import org.scalatest.matchers.ShouldMatchers

    import net.liftweb._
    import common._
    import http._
    import util._
    import Helpers._

    trait BaseWordSpec extends WordSpec with ShouldMatchers

    trait BaseMongoWordSpec extends BaseWordSpec with MongoSuite {
      def mongoIdentifier = MongoConfig.identifier
    }
    trait BaseMongoSessionWordSpec extends BaseWordSpec with MongoSessionSuite {
      def mongoIdentifier = MongoConfig.identifier
    }

    trait WithSessionSpec extends AbstractSuite { this: Suite =>

      protected def session = new LiftSession("", randomString(20), Empty)

      abstract override def withFixture(test: NoArgTest) {
        S.initIfUninitted(session) { super.withFixture(test) }
      }
    }

And, finally, write some tests:

    package code
    package model

    class CompanySpec extends BaseMongoSessionWordSpec {
      "Company" should {
        ...
      }
    }

The above code is available in the [lift-mongo.g8](https://github.com/eltimn/lift-mongo.g8) giter8 template.
