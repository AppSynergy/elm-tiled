module Simple where

import Graphics.Element as Ele
import Dict
import String
import Json.Decode as Json
import Html

import Tiled


port tmxFile : Signal Json.Value


data : Signal (Result String Tiled.TiledMapXML)
data =
  Signal.map (Json.decodeValue Tiled.decode) tmxFile


main : Signal Html.Html
main =
  Signal.map view data

-- VIEW

view : Result String Tiled.TiledMapXML -> Html.Html
view data =
  case data of
    Ok value ->
        Html.div [] [Html.fromElement <| Ele.show value]
    Err error ->
      Html.text error
