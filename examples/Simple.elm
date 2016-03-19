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

-- VIEW

view : Result String Tiled.TiledMapXML -> Html.Html
view data =
  case data of
    Ok value ->
        Html.div [] [Html.fromElement <| Ele.show value]
    Err error ->
      Html.text error
