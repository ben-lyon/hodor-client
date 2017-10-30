module Main exposing (..)

import Html exposing (Html)

import Commands exposing (getAvailability)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (Location)
import Routing exposing (parseLocation)
import Update exposing (update)
import View exposing (view)



init : (List MeetingRoom) -> Route -> ( Model, Cmd Msg )
init meetingRooms route =
    ( Model meetingRooms route, getAvailability meetingRooms )


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init [] HomeRoute
        , update = update
        , subscriptions = always Sub.none
        }
