module Main exposing (..)

import Html exposing (Html)

import Commands exposing (getAvailability)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (Location)
import Routing exposing (parseLocation)
import Update exposing (update)
import View exposing (view)



init : (List MeetingRoom) -> (List ScheduledMeeting) -> Route -> ( Model, Cmd Msg )
init meetingRooms roomSchedule route =
    ( Model meetingRooms roomSchedule route, getAvailability meetingRooms )


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init [] [] HomeRoute
        , update = update
        , subscriptions = always Sub.none
        }
