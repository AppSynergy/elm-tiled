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
toHtml = Html.fromElement << Ele.show


view : Result String Tiled.TiledMapXML -> Html.Html
view data =
  case data of
    Ok tmx ->
        Html.div []
          [ Html.h2 [] [Html.text "Simple output"]
          --, toHtml tmx
          , toHtml <| Tiled.getLayer tmx "TileLayer"
          , toHtml <| Tiled.getFilledLayer tmx "TileLayer"
          ]
    Err error ->
      Html.text error
