module Tiled where

import Json.Decode as Json
import Html exposing (Html)

import Decoders.TiledMapXML as TMX
import Examples.Summary as Summary


-- MODEL

type alias TMXResult = Result String TMX.TiledMapXML


-- VIEW

view : TMXResult -> Html
view data =
  case data of
    Ok value ->
      Summary.view value
    Err error ->
      Html.text error


-- SIGNALS

port tiledjson : Signal Json.Value


data : Signal TMXResult
data =
  Signal.map (Json.decodeValue TMX.decoder) tiledjson


main : Signal Html
main =
  Signal.map view data
