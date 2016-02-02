module Examples.Summary where

import Decoders.TiledMapXML as TMX
import Decoders.Tileset exposing (Tileset)
import Decoders.Tile exposing (Tile)

import Html exposing (..)
import Html.Attributes exposing (..)
import Graphics.Element exposing (show)


view : TMX.TiledMapXML -> Html
view data =
  div [class "summary"]
    [ div [class "tilesets"]
      [ h1 [] [text "Tilesets"]
      , div [] (List.map viewTileset data.tilesets)
      ]
    ]


viewTileset : Tileset -> Html
viewTileset ts =
  let
    dims ts = " (" ++ (toString ts.tileheight) ++
      "x" ++ (toString ts.tileheight) ++ ")"
  in
  div []
    [ h2 [] [text (ts.name ++ (dims ts))]
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
