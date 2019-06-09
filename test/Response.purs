module Payload.Test.Response where

import Prelude

import Data.Either (Either(..), note)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Payload.Response (Json(..), RawResponse(..), ResponseBody(..), Status(..), mkResponse)
import Payload.Status as Status
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert

_header :: forall r. String -> RawResponse r -> Either String String
_header key res = do
  let headers = (unwrap res).headers
  note ("No header with key '" <> key <> "'") $ Map.lookup key headers

_status :: forall r. RawResponse r -> Either String Int
_status res = Right $ (unwrap res).status.code

_body :: forall r. RawResponse r -> Either String (ResponseBody r)
_body res = Right $ (unwrap res).body

tests :: TestSuite
tests = suite "Response" do
  suite "Responder" do
    suite "RawResponse" do
      test "leaves response untouched" do
        let rawRes = RawResponse {status: Status.accepted, headers: Map.empty, body: StringBody "foo"}
        res <- mkResponse rawRes
        Assert.equal (Right rawRes) res
    suite "string" do
      test "sets status to 200" do
        res <- mkResponse "foo"
        Assert.equal (Right 200) (res >>= _status)
      test "sets Content-Type to text/plain" do
        res <- mkResponse "foo"
        Assert.equal (Right "text/plain") (res >>= _header "Content-Type")
      test "leaves body untouched" do
        res <- mkResponse "foo"
        Assert.equal (Right (StringBody "foo")) (res >>= _body)
    suite "Status" do
      test "overrides status of inner response" do
        res <- mkResponse (Status Status.internalServerError "foo")
        Assert.equal (Right Status.internalServerError.code) (res >>= _status)
    suite "record (treated as JSON)" do
      test "sets status to 200" do
        res <- mkResponse { id: 1 }
        Assert.equal (Right 200) (res >>= _status)
      test "sets Content-Type to application/json" do
        res <- mkResponse { id: 1 }
        Assert.equal (Right "application/json") (res >>= _header "Content-Type")
      test "encodes body" do
        res <- mkResponse { id: 1 }
        Assert.equal (Right (StringBody "{\"id\":1}")) (res >>= _body)
    suite "array (treated as JSON)" do
      test "sets status to 200" do
        res <- mkResponse [1, 2, 3]
        Assert.equal (Right 200) (res >>= _status)
      test "sets Content-Type to application/json" do
        res <- mkResponse [1, 2, 3]
        Assert.equal (Right "application/json") (res >>= _header "Content-Type")
      test "encodes body" do
        res <- mkResponse [1, 2, 3]
        Assert.equal (Right (StringBody "[1,2,3]")) (res >>= _body)
    suite "Json" do
      test "sets status to 200" do
        res <- mkResponse (Json [1, 2, 3])
        Assert.equal (Right 200) (res >>= _status)
      test "sets Content-Type to application/json" do
        res <- mkResponse (Json [1, 2, 3])
        Assert.equal (Right "application/json") (res >>= _header "Content-Type")
      test "encodes body as JSON" do
        res <- mkResponse (Json [1, 2, 3])
        Assert.equal (Right (StringBody "[1,2,3]")) (res >>= _body)
      test "encodes string body as JSON" do
        res <- mkResponse (Json "hello")
        Assert.equal (Right (StringBody "\"hello\"")) (res >>= _body)
      test "encodes int body as JSON" do
        res <- mkResponse (Json 1)
        Assert.equal (Right (StringBody "1")) (res >>= _body)
    suite "Maybe" do
      test "returns 404 if response is Nothing" do
        res <- mkResponse (Nothing :: Maybe String)
        Assert.equal (Right 404) (res >>= _status)
      test "returns empty body if response is Nothing" do
        res <- mkResponse (Nothing :: Maybe String)
        Assert.equal (Right EmptyBody) (res >>= _body)
      test "returns inner response status if response is Just" do
        res <- mkResponse (Just {foo: 1})
        Assert.equal (Right 200) (res >>= _status)
      test "returns inner response body if response is Just" do
        res <- mkResponse (Just {foo: 1})
        Assert.equal (Right (StringBody "{\"foo\":1}")) (res >>= _body)