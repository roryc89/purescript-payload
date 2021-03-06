module Payload.Test.Integration.Server.Routing where

import Prelude

import Data.List (List)
import Data.Maybe (Maybe(..))
import Payload.Spec (GET, POST, PUT, Spec(Spec), DELETE)
import Payload.Test.Helpers (respMatches, withRoutes)
import Payload.Test.Helpers as Helpers
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert
  
tests :: TestSuite
tests = do
  let { get, post, put, delete } = Helpers.request "http://localhost:3000"
  suite "Routing" do
    suite "URL params" do
      test "sending valid URL params returns 200 response" $ do
        let spec = Spec :: _ { foo :: GET "/foo/<id>" { params :: { id :: Int }, response :: String }
                             , foo2 :: GET "/foo/<..any>" { params :: { any :: List String }, response :: String } }
        let handlers = { foo: \{params: {id}} -> pure "foo"
                       , foo2: \{params: {any}} -> pure "foo2" }
        withRoutes spec handlers do
            res <- get "/foo/12"
            respMatches { status: 200, body: "foo" } res
      test "sending invalid URL params forwards to next matching handler" $ do
        let spec = Spec :: _ { foo :: GET "/foo/<id>" { params :: { id :: Int }, response :: String }
                             , foo2 :: GET "/foo/<..any>" { params :: { any :: List String }, response :: String } }
        let handlers = { foo: \{params: {id}} -> pure "foo"
                       , foo2: \{params: {any}} -> pure "foo2" }
        withRoutes spec handlers do
            res <- get "/foo/asdf"
            respMatches { status: 200, body: "foo2" } res
    suite "query params" do
      test "sending valid query params returns 200 response" $ do
        let spec = Spec :: _ { foo :: GET "/foo?id=<id>"
                               { query :: { id :: Int }
                               , response :: String } }
        let handlers = { foo: \{query: {id}} -> pure (show id)}
        withRoutes spec handlers do
            res <- get "/foo?id=2"
            respMatches { status: 200, body: "2" } res
      test "sending invalid query params returns 400 Bad Request" $ do
        let spec = Spec :: _ { foo :: GET "/foo?id=<id>"
                               { query :: { id :: Int }
                               , response :: String } }
        let handlers = { foo: \{query: {id}} -> pure (show id) }
        withRoutes spec handlers do
            res <- get "/foo?id=asdf"
            respMatches { status: 400, body: "" } res
    suite "body decoding" do
      test "sending a valid POST body returns valid 200 response" $ do
        let spec = Spec :: _ { foo :: POST "/foo" { body :: { id :: Int }, response :: String } }
        let handlers = { foo: \{body} -> pure (show body.id) }
        withRoutes spec handlers do
            res <- post "/foo" "{\"id\": 5}"
            respMatches { status: 200, body: "5" } res
      test "sending an invalid POST body returns 400 Bad Request" $ do
        let spec = Spec :: _ { foo :: POST "/foo" { body :: { id :: Int }, response :: String } }
        let handlers = { foo: \{body} -> pure (show body) }
        withRoutes spec handlers do
            res <- post "/foo" "asdf"
            respMatches { status: 400, body: "" } res
      test "sending a valid PUT body returns valid 200 response" $ do
        let spec = Spec :: _ { foo :: PUT "/foo" { body :: { id :: Int }, response :: String } }
        let handlers = { foo: \{body} -> pure (show body.id) }
        withRoutes spec handlers do
            res <- put "/foo" "{\"id\": 5}"
            respMatches { status: 200, body: "5" } res
      test "sending an invalid PUT body returns 400 Bad Request" $ do
        let spec = Spec :: _ { foo :: PUT "/foo" { body :: { id :: Int }, response :: String } }
        let handlers = { foo: \{body} -> pure (show body) }
        withRoutes spec handlers do
            res <- put "/foo" "asdf"
            respMatches { status: 400, body: "" } res
      test "sending a valid DELETE body returns valid 200 response" $ do
        let spec = Spec :: _ { foo :: DELETE "/foo" { body :: { id :: Int }, response :: String } }
        let handlers = { foo: \{body} -> pure (show body.id) }
        withRoutes spec handlers do
            res <- delete "/foo" (Just "{\"id\": 5}")
            respMatches { status: 200, body: "5" } res
      test "sending an invalid DELETE body returns 400 Bad Request" $ do
        let spec = Spec :: _ { foo :: DELETE "/foo" { body :: { id :: Int }, response :: String } }
        let handlers = { foo: \{body} -> pure (show body) }
        withRoutes spec handlers do
            res <- delete "/foo" (Just "asdf")
            respMatches { status: 400, body: "" } res
