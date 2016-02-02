module Decoders.Tileset where

import Json.Decode exposing (Decoder,(:=),keyValuePairs,int,string)

type alias Tile = ( String, List ( String, String ) )

type alias Tileset =
  { name : String
  , tileheight : Int
  , tilewidth : Int
  , tilecount : Int
  , tiles : List Tile
  -- , properties : ?
  -- , spacing : Int  ...etc
  }


decoder : Decoder Tileset
decoder =
    Json.Decode.object5 Tileset
      ("name" := string)
      ("tileheight" := int)
      ("tilewidth" := int)
      ("tilecount" := int)
      ("tiles" := (keyValuePairs (keyValuePairs string)))
