module Tiled where

import Dict exposing (Dict)
import Json.Decode as De exposing (Decoder,(:=))


-- MODELS

type alias TiledMapXML =
  { height : Int
  , width : Int
  , tileheight : Int
  , tilewidth : Int
  , layers : List Layer
  , tilesets : List Tileset
  , version : Int
  , nextobjectid : Int
  --, renderorder : String
  --, orientation : String
  --, properties : List Object
  }


type alias Tileset =
  { name : String
  , height : Int
  , width : Int
  , tilecount : Int
  , firstgid : Int
  , tiles : List (String, Tile)
  -- , properties :
  , spacing : Int
  }


type alias Tile =
  { image : String
  , terrain : Maybe (List Int)
  }


type alias Layer =
  { height : Int
  , width : Int
  , x : Int
  , y : Int
  , name : String
  , data : List Int
  , layerType : String
  --, visible : Bool?
  , opacity : Int
  }


-- DECODERS

decode : Decoder TiledMapXML
decode =
  De.object8 TiledMapXML
    ("height" := De.int)
    ("width" := De.int)
    ("tileheight" := De.int)
    ("tilewidth" := De.int)
    ("layers" := (De.list decodeLayer))
    ("tilesets" := (De.list decodeTileSet))
    ("version" := De.int)
    ("nextobjectid" := De.int)


decodeTileSet : Decoder Tileset
decodeTileSet =
  De.object7 Tileset
    ("name" := De.string)
    ("tileheight" := De.int)
    ("tilewidth" := De.int)
    ("tilecount" := De.int)
    ("firstgid" := De.int)
    ("tiles" := (De.keyValuePairs decodeTile))
    ("spacing" := De.int)


decodeTile : Decoder Tile
decodeTile =
  De.object2 Tile
    ("image" := De.string)
    (De.maybe ("terrain" := (De.list De.int)))


decodeLayer : Decoder Layer
decodeLayer =
  De.object8 Layer
    ("height" := De.int)
    ("width" := De.int)
    ("x" := De.int)
    ("y" := De.int)
    ("name" := De.string)
    ("data" := (De.list De.int))
    ("type" := De.string)
    ("opacity" := De.int)


-- INIT

emptyLayer : Layer
emptyLayer =
  { name = "EMPTY", layerType = "EMPTY"
  , height = 0, width = 0, x = 0, y = 0 , opacity = 0
  , data = []
  }


emptyTileset : Tileset
emptyTileset =
  { name = "EMPTY"
  , firstgid = 0 , height = 0 , width = 0, tilecount = 0, spacing = 0
  , tiles = []
  }


emptyTile : Tile
emptyTile =
  { image = "NONE"
  , terrain = Nothing
  }

-- METHODS

type alias LayerDict = Dict String Layer
type alias TilesetDict = Dict String (Dict String Tile)
type alias TileDict = Dict String Tile


layerDict : TiledMapXML -> LayerDict
layerDict tmx =
  let
    entry = \layer dict -> Dict.insert layer.name layer dict
  in
  List.foldl entry Dict.empty tmx.layers


tilesetDict : TiledMapXML -> TilesetDict
tilesetDict tmx =
  let
    entry = \ts dict -> Dict.insert ts.name (tileDict ts) dict
  in
  List.foldl entry Dict.empty tmx.tilesets


tileDict : Tileset -> TileDict
tileDict tileset =
  let
    entry = \(tileid,tileobj) dict -> Dict.insert tileid tileobj dict
  in
  List.foldl entry Dict.empty tileset.tiles


getLayer : TiledMapXML -> String -> Layer
getLayer tmx layerName =
  layerDict tmx
    |> Dict.get layerName
    |> Maybe.withDefault emptyLayer


getTileDict : TiledMapXML -> String -> TileDict
getTileDict tmx tilesetId =
  tilesetDict tmx
    |> Dict.get tilesetId
    |> Maybe.withDefault Dict.empty


getTile : TileDict -> String -> Tile
getTile tileDict tileId =
  Maybe.withDefault emptyTile (Dict.get tileId tileDict)


splitl : Int -> List a -> List (List a)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
