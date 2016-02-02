module Tiled where

import Json.Encode
import Json.Decode as Json exposing (..)
import Graphics.Element as Ele


port tiledjson : Signal Json.Encode.Value


main = Signal.map Ele.show get


get : Signal (Result String TiledJson)
get =
  Signal.map (Json.decodeValue tiledDecoder) tiledjson


type alias TiledJson =
  { height : Int
  , width : Int
  , tileheight : Int
  , tilewidth : Int
  , layers : String
  , tilesets : String
  --, version : Int
  --, nextobjectid : Int
  --, renderorder : String
  --, orientation : String
  --, properties : List Object
  }


tiledDecoder : Json.Decoder TiledJson
tiledDecoder =
    Json.object6 TiledJson
      ("height" := int)
      ("width" := int)
      ("tileheight" := int)
      ("tilewidth" := int)
      ("layers" := string)
      ("tilesets" := string)
