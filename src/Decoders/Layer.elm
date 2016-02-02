module Decoders.Layer where

import Json.Decode exposing (Decoder,(:=),list,int,string)


type alias Layer =
  { height : Int
  , width : Int
  , x : Int
  , y : Int
  , name : String
  , data : List Int
  --, layerType : String
  --, visible : Bool?
  --, opacity : Int
  }


decoder : Decoder Layer
decoder =
  Json.Decode.object6 Layer
    ("height" := int)
    ("width" := int)
    ("x" := int)
    ("y" := int)
    ("name" := string)
    ("data" := (list int))
