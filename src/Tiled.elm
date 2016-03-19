module Tiled
  ( TiledMapXML, Layer, Tileset, Tile
  , decode
  , getLayer, getFilledLayer
  , getTileDict, getTile
  , layerCount, tilesetCount
  ) where

{-| Decode and use Tiled Map XML (.tmx) files.

# Decode TMX
@docs Decoder, Value

# Fetch layers, tilesets or tiles
@docs getLayer, getTileDict, getTile

# Count Layers or Tilesets
@docs layerCount, tilesetCount
-}

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
  , renderorder : String
  , orientation : String
  --, properties : List Object
  }


type alias Tileset =
  { name : String
  , height : Int
  , width : Int
  , tilecount : Int
  , firstgid : Int
  , tiles : List (String, Tile)
  , properties : List (String, String)
  , spacing : Int
  }


type alias Tile =
  { image : String
  , terrain : Maybe (List Int)
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
type alias TilesetDict = Dict String (Dict String Tile)
type alias TileDict = Dict String Tile


-- DECODERS

{-| Implement the chainable decoder described [here](//groups.google.com/forum/m/#!topic/elm-discuss/2LxEUVe0UBo).
  De.map TiledMapXML ("x" := De.int) >>> ("y" := De.int)
-}
(>>>) : Decoder (a -> b) -> Decoder a -> Decoder b
(>>>) func value =
    De.object2 (<|) func value


{-| Decoder for the entire TMX file.
  decode goodFile -> Ok TiledMapXML
  decode badFile  -> Err String
-}
decode : Decoder TiledMapXML
decode =
  De.map TiledMapXML
    ("height" := De.int) >>>
    ("width" := De.int) >>>
    ("tileheight" := De.int) >>>
    ("tilewidth" := De.int) >>>
    ("layers" := (De.list decodeLayer)) >>>
    ("tilesets" := (De.list decodeTileSet)) >>>
    ("version" := De.int) >>>
    ("nextobjectid" := De.int) >>>
    ("renderorder" := De.string) >>>
    ("orientation" := De.string)


decodeTileSet : Decoder Tileset
decodeTileSet =
  De.map Tileset
    ("name" := De.string) >>>
    ("tileheight" := De.int) >>>
    ("tilewidth" := De.int) >>>
    ("tilecount" := De.int) >>>
    ("firstgid" := De.int) >>>
    ("tiles" := (De.keyValuePairs decodeTile)) >>>
    ("properties" := (De.keyValuePairs De.string)) >>>
    ("spacing" := De.int)


decodeTile : Decoder Tile
decodeTile =
  De.map Tile
    ("image" := De.string) >>>
    (De.maybe ("terrain" := (De.list De.int)))


decodeLayer : Decoder Layer
decodeLayer =
  De.map Layer
    ("height" := De.int) >>>
    ("width" := De.int) >>>
    ("x" := De.int) >>>
    ("y" := De.int) >>>
    ("name" := De.string) >>>
    ("data" := (De.list De.int)) >>>
    ("type" := De.string) >>>
    ("visible" := De.bool) >>>
    ("opacity" := De.int)


-- INIT

emptyLayer : Layer
emptyLayer =
  { name = "EMPTY", layerType = "EMPTY"
  , height = 0, width = 0, x = 0, y = 0
  , opacity = 0, visible = False
  , data = []
  }


emptyTileset : Tileset
emptyTileset =
  { name = "EMPTY"
  , firstgid = 0 , height = 0 , width = 0, tilecount = 0, spacing = 0
  , tiles = [], properties = []
  }


emptyTile : Tile
emptyTile =
  { image = "NONE"
  , terrain = Nothing
  }

-- METHODS

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


layerCount : TiledMapXML -> Int
layerCount tmx =
  Dict.size <| layerDict tmx


tilesetCount : TiledMapXML -> Int
tilesetCount tmx =
  Dict.size <| tilesetDict tmx


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


getFilledLayer : TiledMapXML -> String -> FilledLayer
getFilledLayer tmx layerName =
  let
    layer = getLayer tmx layerName
  in
   fill layer


fill : Layer -> FilledLayer
fill layer =
  let
    data = List.map (\x -> emptyTile) layer.data
  in
  { layer | data = data }


getFilledLayerImage : TiledMapXML -> String -> List Tile
getFilledLayerImage tmx layerName =
  let
    filledLayer = getFilledLayer tmx layerName
  in
  filledLayer.data


getTileDict : TiledMapXML -> String -> TileDict
getTileDict tmx tilesetId =
  tilesetDict tmx
    |> Dict.get tilesetId
    |> Maybe.withDefault Dict.empty


{-| Get a tile from a tile dictionary (wraps `Dict.get` with emptyTile).
  getTile (getTileDict tmx "Tileset Name") "Tile ID"
-}
getTile : TileDict -> String -> Tile
getTile tileDict tileId =
  Maybe.withDefault emptyTile (Dict.get tileId tileDict)


splitl : Int -> List a -> List (List a)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
