module Tiled where

import Decoders.Map as TMX

import Json.Decode as Json
import Graphics.Element as Ele


port tiledjson : Signal Json.Value


main = Signal.map Ele.show get


get : Signal (Result String TMX.Map)
get =
  Signal.map (Json.decodeValue TMX.decoder) tiledjson
