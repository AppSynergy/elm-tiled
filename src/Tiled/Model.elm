module Tiled.Model where

import Dict exposing (Dict)


type alias TiledMapXML =
  { height : Int
  , width : Int
  , tileheight : Int
  , tilewidth : Int
  , layers : List Layer
  , tilesets : List Tileset
  , version : Int
  , nextobjectid : Int
  , renderorder : String
  , orientation : String
  --, properties : List Object
  }


type alias Tileset =
  { name : String
  , tileheight : Int
  , tilewidth : Int
  , tilecount : Int
  , firstgid : Int
  , tiles : List (String, Tile)
  , properties : List (String, String)
  , spacing : Int
  }


type alias Tile =
  { image : String
  , terrain : Maybe (List Int)
  , tileheight : Maybe Int
  , tilewidth : Maybe Int
  }


type alias LayerData = List Int


type alias Layer =
  { height : Int
  , width : Int
  , x : Int
  , y : Int
  , name : String
  , data : LayerData
  , layerType : String
  , visible : Bool
  , opacity : Int
  }

type alias FilledLayer =
  { height : Int
  , width : Int
  , x : Int
  , y : Int
  , name : String
  , data : List Tile
  , layerType : String
  , visible : Bool
  , opacity : Int
  }


type alias LayerDict = Dict String Layer
type alias TilesetDict = Dict String Tileset
type alias TileDict = Dict String Tile
