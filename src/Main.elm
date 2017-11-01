module Main exposing (..)

import Html exposing (Html)

import Commands exposing (getAvailability)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (Location)
import Routing exposing (parseLocation)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)



-- This is so ugly but I don't know a better way to do it
init : (List MeetingRoom) -> RoomSchedule -> Route -> Bool -> Float -> ( Model, Cmd Msg )
init meetingRooms roomSchedule route autoUpdate time =
    ( Model meetingRooms roomSchedule route autoUpdate time, getAvailability meetingRooms )



main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init [] (RoomSchedule (MeetingRoom "" False "" "") []) HomeRoute False 0
        , update = update
        , subscriptions = subscriptions
        }
