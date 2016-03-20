module Tiled
  ( Map, decode
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
import Json.Decode
import Dict exposing (Dict)
import Graphics.Element as Ele
import Graphics.Collage as Draw


-- MODULE EXPORTS

import Tiled.Decoder exposing
  ( decode
  , emptyLayer, emptyTile, emptyTileset
  )


import Tiled.Model exposing
  ( TiledMapXML
  , Tile, TileDict
  , Tileset, TilesetDict
  , Layer, FilledLayer, LayerDict
  )


type alias Map = Tiled.Model.TiledMapXML


decode : Json.Decode.Decoder Map
decode =
  Tiled.Decoder.decode


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
