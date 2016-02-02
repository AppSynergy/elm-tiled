module Decoders.Tile where

import Json.Decode exposing (Decoder,(:=),int,string,list,maybe)


type alias Tile =
  { image : String
  , terrain : Maybe (List Int)
  }


decoder : Decoder Tile
decoder =
  Json.Decode.object2 Tile
    ("image" := string)
    (maybe ("terrain" := (list int)))
