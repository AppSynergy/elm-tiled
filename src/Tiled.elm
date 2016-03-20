module Tiled
  ( TiledMapXML, Layer, Tileset, Tile
  , decode
  , getLayer, getFilledLayer, getFilledLayerImage
  , getAllLayersImage
  , getTileset, getAllTileDict, getAnyTile
  , getTile, getTileElement
  , layerCount, tilesetCount
  , tileDict
  ) where

{-| Decode and use Tiled Map XML (.tmx) files.

# Decode TMX
@docs Decoder, Value

# Fetch layers, tilesets or tiles
@docs getLayer, getTileDict, getTile

# Count Layers or Tilesets
@docs layerCount, tilesetCount
-}

import String
import Color
import Dict exposing (Dict)
import Json.Decode as De exposing (Decoder,(:=))
import Graphics.Element as Ele
import Graphics.Collage as Draw

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
type alias TilesetDict = Dict String Tileset
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
    ("tiles" := ((De.keyValuePairs decodeTile))) >>>
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
  --, height = 0 , width = 0
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
    entry = \ts dict -> Dict.insert ts.name ts dict
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
    key k = case String.toInt k of
      Ok i -> toString (i + tileset.firstgid)
      Err s -> "0"
    entry = \(k, v) dict -> Dict.insert (key k) v dict
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
   fill tmx layer


fill : TiledMapXML -> Layer -> FilledLayer
fill tmx layer =
  let
    data = List.map (\x -> getAnyTile tmx (toString x)) layer.data
  in
  { layer | data = data }


getFilledLayerImage : TiledMapXML -> String -> Ele.Element
getFilledLayerImage tmx layerName =
  let
    filledLayer = getFilledLayer tmx layerName
    elements = filledLayer.data
      |> List.map tileElement
      |> List.map Draw.toForm
      |> splitl tmx.width
      |> List.indexedMap (\i row -> List.indexedMap (\j tile -> positionTile j i tile) row)
      |> List.concat
      |> (::) (Draw.rect 1200 1000 |> Draw.filled Color.blue)
  in
  Draw.collage 1200 1000 elements


getAllLayersImage : TiledMapXML -> Ele.Element
getAllLayersImage tmx =
  layerDict tmx
    |> Dict.map (\k v -> getFilledLayerImage tmx k)
    |> Dict.values
    |> List.map Draw.toForm
    |> Draw.collage 1200 1000


positionTile : Int -> Int -> Draw.Form -> Draw.Form
positionTile w h tile =
  let
    scale = 32
    offset = 450
  in
  tile |> Draw.move
    ( ((toFloat w ) * scale) - offset
    , offset - ((toFloat h) * scale)
    )


getTileset : TiledMapXML -> String -> TileDict
getTileset tmx tilesetId =
  tilesetDict tmx
    |> Dict.get tilesetId
    |> Maybe.withDefault emptyTileset
    |> tileDict


getAllTileDict : TiledMapXML -> TileDict
getAllTileDict tmx =
  let
    entry = \k v all -> Dict.union v all
  in
  tilesetDict tmx
    |> Dict.map (\_ a -> tileDict a)
    |> Dict.foldl entry Dict.empty


getAnyTile: TiledMapXML -> String -> Tile
getAnyTile tmx tileId =
  getAllTileDict tmx
    |> Dict.get tileId
    |> Maybe.withDefault emptyTile


getTile : TileDict -> String -> Tile
getTile tileDict tileId =
  Dict.get tileId tileDict
    |> Maybe.withDefault emptyTile


getTileElement : TileDict -> String -> Ele.Element
getTileElement tileDict tileId =
  getTile tileDict tileId |> tileElement


tileElement : Tile -> Ele.Element
tileElement tile =
  case tile.image of
    "NONE" -> Ele.empty
    _ -> Ele.image 64 64 <| "../assets/" ++ tile.image


splitl : Int -> List a -> List (List a)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
