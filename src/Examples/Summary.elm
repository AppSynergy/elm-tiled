module Examples.Summary where

import Decoders.TiledMapXML as TMX
import Decoders.Tileset exposing (Tileset,Tile)

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
  div []
    [ h2 [] [text (ts.name ++ (dimsTileset ts))]
    , ul [] (List.map viewTile ts.tiles)
    ]


dimsTileset : Tileset -> String
dimsTileset ts =
    " (" ++ (toString ts.tileheight) ++ "x" ++ (toString ts.tileheight) ++ ")"


viewTile : Tile -> Html
viewTile tile =
  li [] [(fromElement (show tile))]
