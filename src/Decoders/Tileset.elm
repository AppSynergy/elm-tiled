module Decoders.Tileset where

import Json.Decode exposing (Decoder,(:=),keyValuePairs,int,string)

import Decoders.Tile as Tile exposing (Tile)


type alias Tileset =
  { name : String
  , height : Int
  , width : Int
  , tilecount : Int
  , firstgid : Int
  , tiles : List (String, Tile)
  -- , properties : ?
  -- , spacing : Int  ...etc
  }


decoder : Decoder Tileset
decoder =
    Json.Decode.object6 Tileset
      ("name" := string)
      ("tileheight" := int)
      ("tilewidth" := int)
      ("tilecount" := int)
      ("firstgid" := int)
      ("tiles" := (keyValuePairs Tile.decoder))
