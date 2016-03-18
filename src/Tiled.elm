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
  --, version : Int
  --, nextobjectid : Int
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
  -- , properties : ?
  -- , spacing : Int  ...etc
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
  --, layerType : String
  --, visible : Bool?
  --, opacity : Int
  }


-- DECODERS

decode : Decoder TiledMapXML
decode =
    De.object6 TiledMapXML
      ("height" := De.int)
      ("width" := De.int)
      ("tileheight" := De.int)
      ("tilewidth" := De.int)
      ("layers" := (De.list decodeLayer))
      ("tilesets" := (De.list decodeTileSet))


decodeTileSet : Decoder Tileset
decodeTileSet =
    De.object6 Tileset
      ("name" := De.string)
      ("tileheight" := De.int)
      ("tilewidth" := De.int)
      ("tilecount" := De.int)
      ("firstgid" := De.int)
      ("tiles" := (De.keyValuePairs decodeTile))


decodeTile : Decoder Tile
decodeTile =
  De.object2 Tile
    ("image" := De.string)
    (De.maybe ("terrain" := (De.list De.int)))


decodeLayer : Decoder Layer
decodeLayer =
  De.object6 Layer
    ("height" := De.int)
    ("width" := De.int)
    ("x" := De.int)
    ("y" := De.int)
    ("name" := De.string)
    ("data" := (De.list De.int))


-- INIT

emptyTileset : Tileset
emptyTileset =
  { name = "EMPTY"
  , firstgid = 0 , height = 0 , width = 0, tilecount = 0
  , tiles = []
  }

emptyTile : Tile
emptyTile =
  { image = "NONE"
  , terrain = Nothing
  }




-- METHODS

layers : TiledMapXML -> List Layer
layers data = data.layers


type alias TilesetDict = Dict String (Dict String Tile)
type alias TileDict = Dict String Tile

tilesetDict : TiledMapXML -> TilesetDict
tilesetDict data =
  let
    entry = \ts dict -> Dict.insert ts.name (tileDict ts) dict
  in
  List.foldl entry Dict.empty data.tilesets


tileDict : Tileset -> TileDict
tileDict tileset =
  let
    entry = \(tileid,tileobj) dict -> Dict.insert tileid tileobj dict
  in
  List.foldl entry Dict.empty tileset.tiles


getTileDict : TilesetDict -> String -> TileDict
getTileDict tilesetDict tilesetId =
  Maybe.withDefault Dict.empty (Dict.get tilesetId tilesetDict)


getTile : TileDict -> String -> Tile
getTile tileDict tileId =
  Maybe.withDefault emptyTile (Dict.get tileId tileDict)


splitl : Int -> List a -> List (List a)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
