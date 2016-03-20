module Tiled
  ( Map, decode
  , getLayer, getFilledLayer, getFilledLayerImage
  , getAllLayersImage
  , getTileset, getAllTileDict, getAnyTile
  , getTile
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
import Graphics.Element exposing (Element)
import Graphics.Collage as Draw


-- MODULE EXPORTS

import Tiled.Graphics

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


-- LAYERS

layerCount : TiledMapXML -> Int
layerCount tmx =
  Dict.size <| layerDict tmx


layerDict : TiledMapXML -> LayerDict
layerDict tmx =
  let
    entry layer dict = Dict.insert layer.name layer dict
  in
  List.foldl entry Dict.empty tmx.layers


getLayer : TiledMapXML -> String -> Layer
getLayer tmx layerName =
  layerDict tmx
    |> Dict.get layerName
    |> Maybe.withDefault emptyLayer


getFilledLayer : TiledMapXML -> String -> FilledLayer
getFilledLayer tmx layerName =
  getLayer tmx layerName
    |> Tiled.Graphics.fill (\x -> getAnyTile tmx (toString x))


getFilledLayerImage : TiledMapXML -> String -> Element
getFilledLayerImage tmx layerName =
  getFilledLayer tmx layerName
    |> Tiled.Graphics.filledLayerImage


getAllLayersImage : TiledMapXML -> Element
getAllLayersImage tmx =
  layerDict tmx
    |> Dict.map (\k v -> getFilledLayerImage tmx k)
    |> Dict.values
    |> List.map Draw.toForm
    |> Draw.collage 1200 1000


-- TILESETS

tilesetCount : TiledMapXML -> Int
tilesetCount tmx =
  Dict.size <| tilesetDict tmx


tilesetDict : TiledMapXML -> TilesetDict
tilesetDict tmx =
  let
    entry ts dict = Dict.insert ts.name ts dict
  in
  List.foldl entry Dict.empty tmx.tilesets


getTileset : TiledMapXML -> String -> TileDict
getTileset tmx tilesetId =
  tilesetDict tmx
    |> Dict.get tilesetId
    |> Maybe.withDefault emptyTileset
    |> tileDict


-- TILES

tileDict : Tileset -> TileDict
tileDict tileset =
  let
    key k = case String.toInt k of
      Ok i -> toString (i + tileset.firstgid)
      Err s -> "0"
    entry (k, v) dict = Dict.insert (key k) v dict
  in
  List.foldl entry Dict.empty tileset.tiles


getAllTileDict : TiledMapXML -> TileDict
getAllTileDict tmx =
  let
    entry k v all = Dict.union v all
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


getTileElement : TileDict -> String -> Element
getTileElement tileDict tileId =
  getTile tileDict tileId
    |> Tiled.Graphics.tileElement
