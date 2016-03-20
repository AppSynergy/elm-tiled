module Tiled.Graphics where

import Color
import Dict
import Graphics.Element as Element exposing (Element)
import Graphics.Collage as Draw

import Tiled.Model exposing
  ( TiledMapXML, TileDict, Tile
  , Layer, FilledLayer
  )


tileElement : Tile -> Element
tileElement tile =
  case tile.image of
    "NONE" -> Element.empty
    _ -> Element.image 64 64 <| "../assets/" ++ tile.image


pos : Int -> Int -> Draw.Form -> Draw.Form
pos w h tile =
  let
    scale = 32
    offset = 450
  in
  tile |> Draw.move
    ( ((toFloat w ) * scale) - offset
    , offset - ((toFloat h) * scale)
    )


filledLayerImage : FilledLayer -> Element
filledLayerImage filledLayer =
  let
    elements = filledLayer.data
      |> List.map tileElement
      |> List.map Draw.toForm
      |> splitl 32
      |> List.indexedMap (\i row -> List.indexedMap (\j tile -> pos j i tile) row)
      |> List.concat
      |> (::) (Draw.rect 1200 1000 |> Draw.filled Color.blue)
  in
  Draw.collage 1200 1000 elements


fill : (Int -> Tile) -> Layer -> FilledLayer
fill tileFiller layer =
  { layer | data = List.map tileFiller layer.data }


splitl : Int -> List a -> List (List a)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
