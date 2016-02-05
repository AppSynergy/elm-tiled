module Examples.Draw where

import Decoders.TiledMapXML as TMX
import Decoders.Tileset exposing (Tileset)
import Decoders.Tile exposing (Tile)
import Decoders.Layer exposing (Layer)

import Examples.Summary as S

import Html exposing (..)
import Html.Attributes exposing (..)
import Graphics.Element exposing (show)
import String
import Dict

-- VIEW

view : TMX.TiledMapXML -> Html
view data =
  let
    l : Maybe Layer
    l = List.head data.layers
    y : List String
    y = case l of
      Just a ->
        List.map toString a.data
      Nothing ->
        []

  in
  div [class "summary"]
    [ div [] (List.map (paint data.tilesets) y)
    , div [] (List.map S.viewTileset data.tilesets)
    ]


type alias DictTiles = Dict.Dict String Html

paint : List Tileset -> String -> Html
paint tiles x =
  tiles
    |> List.map images
    |> List.foldl Dict.union Dict.empty
    |> Dict.get x
    |> Maybe.withDefault (text "x")


images : Tileset -> DictTiles
images tileset =
  let
    gid fgid tile =
      let
        intId : Result String Int
        intId = String.toInt (fst tile)
        mid : Int
        mid = case intId of
          Ok i -> i + fgid
          Err s -> 0
        in
        toString mid
    pic tile = img
      [ src ("../assets/" ++ (snd tile).image )
      , width 32
      , height 32
      , class "image"
      ] []
    g = tileset.firstgid
  in
  tileset.tiles
    |> List.map (\t -> (gid tileset.firstgid t, pic t))
    |> Dict.fromList


splitl : Int -> List a -> List (List a)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
