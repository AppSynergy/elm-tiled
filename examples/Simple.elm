module Simple where

import Graphics.Element as Ele
import Dict
import String
import Json.Decode as Json
import Html

import Tiled


port tmxFile : Signal Json.Value


main : Signal Html.Html
main =
  tmxFile
    |> Signal.map (Json.decodeValue Tiled.decode)
    |> Signal.map view


toHtml : a -> Html.Html
toHtml x =
  Html.fromElement (Ele.show x)


view : Result String Tiled.TiledMapXML -> Html.Html
view data =
  case data of
    Ok tmx ->
        let
          tileDict = Tiled.getTileDict tmx "Tiles"
        in Html.div []
          [ Html.h2 [] [Html.text "Simple output"]
          --, toHtml tmx
          , toHtml <| Tiled.getLayer tmx "TileLayer"
          , Html.fromElement <| Tiled.getFilledLayerImage tmx "TileLayer"
          , toHtml <| Tiled.getTile tileDict "4"
          , Html.fromElement <| Tiled.getTileElement tileDict "4"
          --, toHtml <| Tiled.getAllTileDict tmx
          ]
    Err error ->
      Html.text error
