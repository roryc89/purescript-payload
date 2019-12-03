module Payload.Test.Integration.Client.QueryParams where

import Prelude

import Data.Either (Either(..))
import Data.Tuple (Tuple(..))
import Foreign.Object (Object)
import Foreign.Object as Object
import Payload.Client (mkClient)
import Payload.ResponseTypes (Empty(..))
import Payload.Server.Response as Response
import Payload.Spec (DELETE, GET, POST, PUT, Spec(Spec), HEAD)
import Payload.Test.Config (TestConfig)
import Payload.Test.Helpers (bodyEquals, withRoutes)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert
  
tests :: TestConfig -> TestSuite
tests cfg = do
  suite "QueryParams" do
    test "succeeds with query literal" $ do
      let spec = Spec :: _ { foo :: GET "/foo?secret"
                                     { response :: String } }
      let handlers = { foo: \_ -> pure "Response" }
      withRoutes spec handlers do
        let client = mkClient cfg.clientOpts spec
        res <- client.foo {}
        bodyEquals "Response" res
    test "succeeds with query key" $ do
      let spec = Spec :: _ { foo :: GET "/foo?secret=<secret>"
                                     { query :: { secret :: String }
                                     , response :: String } }
      let handlers = { foo: \{ query: { secret } } -> pure secret }
      withRoutes spec handlers do
        let client = mkClient cfg.clientOpts spec
        res <- client.foo { query: { secret: "something" } }
        bodyEquals "something" res
    test "succeeds with multimatch" $ do
      let spec = Spec :: _ { foo :: GET "/foo?<..any>"
                                     { query :: { any :: Object String }
                                     , response :: String } }
      let handlers = { foo: \{ query: { any } } -> pure (show any) }
      withRoutes spec handlers do
        let client = mkClient cfg.clientOpts spec
        res <- client.foo { query: { any: Object.fromFoldable [Tuple "foo" "foo1", Tuple "bar" "bar1"] } }
        let expected = "(fromFoldable [(Tuple \"foo\" \"\\\"foo1\\\"\"),(Tuple \"bar\" \"\\\"bar1\\\"\")])"
        bodyEquals expected res
    test "GET succeeds" $ do
      let spec = Spec :: _ { foo :: GET "/foo?literal&key=<key>&<..rest>"
                                     { query :: { key :: Int, rest :: Object String }
                                     , response :: String } }
      let handlers = { foo: \{ query: { key, rest } } -> pure $ "key " <> show key <> ", " <> show rest }
      withRoutes spec handlers do
        let client = mkClient cfg.clientOpts spec
        res <- client.foo { query: { key: 1, rest: Object.fromFoldable [Tuple "a" "a"] } }
        let expected = "key 1, (fromFoldable [(Tuple \"literal\" \"\"),(Tuple \"a\" \"\\\"a\\\"\")])"
        bodyEquals expected res
    test "POST succeeds" $ do
      let spec = Spec :: _ { foo :: POST "/foo?literal&key=<key>&<..rest>"
                                     { query :: { key :: Int, rest :: Object String }
                                     , body :: String
                                     , response :: String } }
      let handlers = { foo: \({ query: { key, rest } }) -> pure $ "key " <> show key <> ", " <> show rest }
      withRoutes spec handlers do
        let client = mkClient cfg.clientOpts spec
        res <- client.foo { body: "_", query: { key: 1, rest: Object.fromFoldable [Tuple "a" "a"] } }
        let expected = "key 1, (fromFoldable [(Tuple \"literal\" \"\"),(Tuple \"a\" \"\\\"a\\\"\")])"
        bodyEquals expected res
    test "HEAD succeeds" $ do
      let spec = Spec :: _ { foo :: HEAD "/foo?literal&key=<key>&<..rest>"
                                     { query :: { key :: Int, rest :: Object String }} }
      let handlers = { foo: \{ query: { key, rest } } -> pure $ Empty }
      withRoutes spec handlers do
        let client = mkClient cfg.clientOpts spec
        res <- client.foo { query: { key: 1, rest: Object.fromFoldable [Tuple "a" "a"] } }
        bodyEquals "" res
    test "DELETE succeeds" $ do
      let spec = Spec :: _ { foo :: DELETE "/foo?literal&key=<key>&<..rest>"
                                     { query :: { key :: Int, rest :: Object String }
                                     , body :: String
                                     , response :: String } }
      let handlers = { foo: \({ query: { key, rest } }) -> pure $ "key " <> show key <> ", " <> show rest }
      withRoutes spec handlers do
        let client = mkClient cfg.clientOpts spec
        res <- client.foo { body: "_", query: { key: 1, rest: Object.fromFoldable [Tuple "a" "a"] } }
        let expected = "key 1, (fromFoldable [(Tuple \"literal\" \"\"),(Tuple \"a\" \"\\\"a\\\"\")])"
        bodyEquals expected res
    test "PUT succeeds" $ do
      let spec = Spec :: _ { foo :: PUT "/foo?literal&key=<key>&<..rest>"
                                     { query :: { key :: Int, rest :: Object String }
                                     , body :: String
                                     , response :: String } }
      let handlers = { foo: \({ query: { key, rest } }) -> pure $ "key " <> show key <> ", " <> show rest }
      withRoutes spec handlers do
        let client = mkClient cfg.clientOpts spec
        res <- client.foo { body: "_", query: { key: 1, rest: Object.fromFoldable [Tuple "a" "a"] } }
        let expected = "key 1, (fromFoldable [(Tuple \"literal\" \"\"),(Tuple \"a\" \"\\\"a\\\"\")])"
        bodyEquals expected res
