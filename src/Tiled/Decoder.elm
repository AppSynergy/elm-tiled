module Tiled.Decoder where

import Json.Decode as De exposing (Decoder,(:=))

import Tiled.Model exposing (TiledMapXML, Tile, Tileset, Layer)

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
    (De.maybe ("terrain" := (De.list De.int))) >>>
    (De.maybe ("tileheight" := De.int)) >>>
    (De.maybe ("tilewidth" := De.int))


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
  , tileheight = Nothing , tilewidth = Nothing
  }
