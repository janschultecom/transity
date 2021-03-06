module Transity.Data.Entity where

import Prelude

import Data.Argonaut.Core (toObject, Json)
import Data.Argonaut.Decode.Class (class DecodeJson)
import Data.DateTime (DateTime)
import Data.Result (Result(..), toEither)
import Data.String (joinWith)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(Nothing), maybe, fromMaybe)
import Transity.Data.Account (Account)
import Transity.Data.Account as Account
import Transity.Utils
  ( getObjField
  , getFieldMaybe
  , stringToDateTime
  , dateShowPretty
  )


newtype Entity = Entity
  { id :: String
  , name :: Maybe String
  , note :: Maybe String
  , utc :: Maybe DateTime
  , tags :: Maybe (Array String)
  , accounts :: Maybe (Array Account)
  }

derive instance genericEntity :: Generic Entity _

instance showEntity :: Show Entity where
  show = genericShow

instance decodeEntity :: DecodeJson Entity where
  decodeJson json = toEither $ decodeJsonEntity json


decodeJsonEntity :: Json -> Result String Entity
decodeJsonEntity json = do
  object <- maybe (Error "Entity is not an object") Ok (toObject json)

  id       <- object `getObjField` "id"
  name     <- object `getFieldMaybe` "name"
  note     <- object `getFieldMaybe` "note"
  utc      <- object `getFieldMaybe` "utc"
  tags     <- object `getFieldMaybe` "tags"
  accounts <- object `getFieldMaybe` "accounts"

  pure $ Entity
    { id
    , name
    , note
    , utc: utc >>= stringToDateTime
    , tags
    , accounts
    }


zero :: Entity
zero = Entity
  { id: ""
  , name: Nothing
  , note: Nothing
  , utc: Nothing
  , tags: Nothing
  , accounts: Nothing
  }


showPretty :: Entity -> String
showPretty (Entity entity) =
  entity.id
  <> " | "
  <> (fromMaybe "" entity.name)
  <> " | "
  <> (fromMaybe "" entity.note)
  <> " | "
  <> (fromMaybe "" (entity.utc <#> dateShowPretty))
  <> " | "
  <> (joinWith ", " $ fromMaybe [] entity.tags)
  <> " | "
  <> (joinWith ", " $ map Account.showPretty $ fromMaybe [] entity.accounts)
