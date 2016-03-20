module Tiled.Graphics where

import Color
import Dict
import Graphics.Element as Element exposing (Element)
import Graphics.Collage as Draw

import Tiled.Model exposing
  ( TiledMapXML, TileDict, Tileset, Tile
  , Layer, FilledLayer
  )


type alias FormMatrix = List (List Draw.Form)


tileElement : Tile -> Element
tileElement tile =
  let
    globalScale = 0.5
    scale x = toFloat x |> (*) globalScale |> round
    h = Maybe.withDefault 16 tile.tileheight |> scale
    w = Maybe.withDefault 16 tile.tilewidth |> scale
  in
  case tile.image of
    "NONE" -> Element.empty
    _ -> Element.image w h <| "../assets/" ++ tile.image


setPositions : Int -> Int -> FormMatrix -> FormMatrix
setPositions width height matrix =
  let
    globalScale = 0.5
    scaleX = toFloat width
    scaleY = toFloat height
    offsetX = 450
    offsetY = 543
    pos w h = Draw.move
      ( ((toFloat w ) * scaleX * globalScale) - offsetX
      , offsetY - ((toFloat h) * scaleY * globalScale)
      )
    im = List.indexedMap
  in
  im (\i r -> im (\j t -> pos j i t) r) matrix


filledLayerImage : TiledMapXML -> FilledLayer -> Element
filledLayerImage tmx filledLayer =
  let
    w = filledLayer.width * tmx.tileheight // 2 |> (+) 150
    h = filledLayer.height * tmx.tilewidth // 2 |> (+) 50
    elements = filledLayer.data
      |> List.map tileElement
      |> List.map Draw.toForm
      |> splitl filledLayer.width
      >> setPositions tmx.tilewidth tmx.tileheight
      >> List.concat
      >> (::) (Draw.rect (toFloat w) (toFloat h) |> Draw.filled Color.blue)
  in
  Draw.collage w h elements


fill : (Int -> Tile) -> Layer -> FilledLayer
fill tileFiller layer =
  { layer | data = List.map tileFiller layer.data }


splitl : Int -> List a -> List (List a)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
