module Examples.Draw where

import Decoders.TiledMapXML as TMX
import Decoders.Tileset exposing (Tileset)
import Decoders.Tile exposing (Tile)
import Decoders.Layer exposing (Layer)

import Examples.Summary as S

import Html exposing (..)
import Html.Attributes exposing (..)
import Graphics.Element as Element exposing (Element,show)
import Graphics.Collage as Draw
import String
import Dict
import Color

type alias Position =
  (Int, Int)
type alias Cell =
  (Position, Element)
type alias Map =
  List (List Cell)

type alias DictTiles =
  Dict.Dict String Element


viewmap : Map -> Element
viewmap map =
  map
    |> List.map (List.map viewcell)
    |> List.map List.reverse
    |> List.concat
    |> List.reverse
    |> Draw.collage 1000 800


viewcell : Cell -> Draw.Form
viewcell (p,ele) =
  let
    pf p =
      ( toFloat (((fst p) * 32) - 1400 )
      , negate (toFloat (((snd p) * 32) - 350 ))
      )
  in
  ele
    |> Draw.toForm
    |> Draw.move (pf p)

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
    z = List.map (\a -> (List.map toString a.data)) data.layers
      |> List.concat
  in
  div [class "summary"]
    [ div [] [(
      z
        |> List.map (paint data.tilesets)
        |> splitl 64
        |> addPosition
        |> viewmap
        |> fromElement
    )]
    , div [] (List.map S.viewTileset data.tilesets)
    ]


addPosition : List (List Element) -> Map
addPosition list2 =
  list2
    |> List.indexedMap toRow


toRow : Int -> List Element -> List Cell
toRow j row =
  row
    |> List.map (\x -> (j,x))
    |> List.indexedMap toPosition


toPosition : Int -> (Int,Element) -> Cell
toPosition i (j,a) =
  ( (i,j), a )


paint : List Tileset -> String -> Element
paint tiles x =
  tiles
    |> List.map images
    |> List.foldl Dict.union Dict.empty
    |> Dict.get x
    |> Maybe.withDefault Element.empty


blank : Maybe Element.Element -> Element.Element
blank =
  [ Draw.rect 32 32
    |> Draw.filled Color.white
  ]
    |> Draw.collage 32 32
    >> Maybe.withDefault


images : Tileset -> DictTiles
images tileset =
  let
    f = tileset.firstgid
    w = tileset.width // 2
    gid f (sid,_) =
      case String.toInt sid of
        Ok i -> toString (i + f)
        Err s -> "0"
    pic w (_,tile) =
      Element.image w w ("../assets/" ++ tile.image )

  in
  tileset.tiles
    |> List.map (\t -> (gid f t, pic w t))
    |> Dict.fromList


splitl : Int -> List Element -> List (List Element)
splitl k xs =
  if List.length xs > k then
    List.take k xs :: splitl k (List.drop k xs)
  else
    [xs]
