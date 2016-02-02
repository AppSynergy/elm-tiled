module Examples.Summary where

import Decoders.TiledMapXML as TMX
import Decoders.Tileset exposing (Tileset)
import Decoders.Tile exposing (Tile)
import Decoders.Layer exposing (Layer)

import Html exposing (..)
import Html.Attributes exposing (..)
import Graphics.Element exposing (show)


view : TMX.TiledMapXML -> Html
view data =
  div [class "summary"]
    [ div [class "tilesets"]
      [ h1 [] [text "Layers"]
      , div [] (List.map viewLayer data.layers)
      , h1 [] [text "Tilesets"]
      , div [] (List.map viewTileset data.tilesets)
      ]
    ]


viewLayer : Layer -> Html
viewLayer layer =
  div [class "layer"]
    [ h2 [] [text (layer.name ++ " " ++ (dimensions layer))]
    , div [] [(viewLayerData layer)]
    ]


viewLayerData : Layer -> Html
viewLayerData layer =
  let
    f = (\y x -> x ++ (toString y))
  in
  div [] [text (List.foldl f " " layer.data)]


viewTileset : Tileset -> Html
viewTileset ts =
  div [class "tileset"]
    [ h2 [] [text (ts.name ++ " " ++ (dimensions ts))]
    , ul [] (List.map viewTile (List.reverse ts.tiles))
    ]


viewTile : (String, Tile) -> Html
viewTile (str, tile) =
  li []
    [ strong [] [text ("id: " ++ str )]
    , em [class "path"] [text tile.image]
    , img
      [ src ("../assets/" ++ tile.image)
      , width 32
      , height 32
      , class "image"
      ] []
    ]


dimensions : { a | height : Int, width : Int } -> String
dimensions x =
  "(" ++ (toString x.width) ++
  "x" ++ (toString x.height) ++ ")"
