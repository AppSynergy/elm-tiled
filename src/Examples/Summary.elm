module Examples.Summary where

import Decoders.TiledMapXML as TMX
import Decoders.Tileset exposing (Tileset)
import Decoders.Tile exposing (Tile)
import Decoders.Layer exposing (Layer)

import Html exposing (..)
import Html.Attributes exposing (..)
import Graphics.Element exposing (show)
import String


view : TMX.TiledMapXML -> Html
view data =
  div [class "summary"]
    [ div [class "tilesets"]
      [ h1 [] [text "Layers"]
      , div [] (List.map (viewLayer data.tilesets) data.layers)
      , h1 [] [text "Tilesets"]
      , div [] (List.map viewTileset data.tilesets)
      ]
    ]


viewLayer : List Tileset -> Layer -> Html
viewLayer tilesets layer =
  div [class "layer"]
    [ h2 [] [text (layer.name ++ " " ++ (dimensions layer))]
    , div [] [(viewLayerData tilesets layer.data layer.width)]
    ]


viewLayerData : List Tileset -> List Int -> Int -> Html
viewLayerData tilesets data width =
  let
    d : List (List Html)
    d = splitl width (List.map (viewLayerTile tilesets) data)
  in
  div []
    (List.map (div [class "row"]) d)


viewLayerTile : List Tileset -> Int -> Html
viewLayerTile tilesets d =
  div [class "tile"]
    [ if d == 0 then
        text ""
      else
        viewLayerTileImg tilesets d
    ]


viewLayerTileImg : List Tileset -> Int -> Html
viewLayerTileImg tilesets d =
  div [class "filled"] [text (toString d)]


viewTileset : Tileset -> Html
viewTileset ts =
  div [class "tileset"]
    [ h2 [] [text (ts.name ++ " " ++ (dimensions ts))]
    , ul [] (List.map (viewTile ts.firstgid) (List.reverse ts.tiles))
    ]


viewTile : Int -> (String, Tile) -> Html
viewTile firstgid (strId, tile) =
  let
    intId = String.toInt strId
    id = case intId of
      Ok i -> i + firstgid
      Err s -> 0
  in
  li []
    [ strong [] [text ("gid: " ++ (toString id) )]
    , em [class "path"] [text tile.image]
    , img
      [ src ("../assets/" ++ tile.image)
      , width 32
      , height 32
      , class "image"
      ] []
    ]


-- HELPERS & UTILS

dimensions : { a | height : Int, width : Int } -> String
dimensions x =
  "(" ++ (toString x.width) ++
  "x" ++ (toString x.height) ++ ")"


splitl : Int -> List a -> List (List a)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
