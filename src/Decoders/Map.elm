module Decoders.Map where

import Json.Decode exposing (Decoder,(:=),list,int)

import Decoders.Layer as Layer exposing (Layer)
import Decoders.Tileset as Tileset exposing (Tileset)


type alias Map =
  { height : Int
  , width : Int
  , tileheight : Int
  , tilewidth : Int
  , layers : List Layer
  , tilesets : List Tileset
  --, version : Int
  --, nextobjectid : Int
  --, renderorder : String
  --, orientation : String
  --, properties : List Object
  }


decoder : Decoder Map
decoder =
    Json.Decode.object6 Map
      ("height" := int)
      ("width" := int)
      ("tileheight" := int)
      ("tilewidth" := int)
      ("layers" := (list Layer.decoder))
      ("tilesets" := (list Tileset.decoder))
