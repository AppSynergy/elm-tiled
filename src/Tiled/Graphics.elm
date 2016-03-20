module Tiled.Graphics where

import Color
import Dict
import Graphics.Element as Element exposing (Element)
import Graphics.Collage as Draw

import Tiled.Model exposing
  ( TiledMapXML, TileDict, Tile
  , Layer, FilledLayer
  )


type alias FormMatrix = List (List Draw.Form)


tileElement : Tile -> Element
tileElement tile =
  case tile.image of
    "NONE" -> Element.empty
    _ -> Element.image 64 64 <| "../assets/" ++ tile.image


setPositions : FormMatrix -> FormMatrix
setPositions matrix =
  let
    scale = 32
    offset = 450
    pos w h = Draw.move
      ( ((toFloat w ) * scale) - offset
      , offset - ((toFloat h) * scale)
      )
    im = List.indexedMap
  in
  im (\i r -> im (\j t -> pos j i t) r) matrix
  --List.indexedMap (\i row -> List.indexedMap (\j tile -> pos j i tile) row) matrix



filledLayerImage : FilledLayer -> Element
filledLayerImage filledLayer =
  let
    elements = filledLayer.data
      |> List.map tileElement
      |> List.map Draw.toForm
      |> splitl 32
      |> setPositions
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
