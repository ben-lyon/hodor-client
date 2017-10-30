module Update exposing (..)

import Msgs exposing (..)
import Models exposing (..)
import Routing exposing (parseLocation)
import Commands exposing (getAvailability, getRoomInfo)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadAvailability ->
            (model, getAvailability model.meetingRooms)
        LoadedAvailability (Ok meetingRooms) ->
            ( Model meetingRooms [] HomeRoute, Cmd.none )
        LoadedAvailability (Err _) ->
            ( model, Cmd.none )
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )
        LoadRoomSchedule roomName ->
            ( { model | route = RoomRoute roomName }, getRoomInfo roomName )
        LoadedRoomSchedule (Ok roomSchedule) ->
            ( { model | roomSchedule = roomSchedule }, Cmd.none )
        LoadedRoomSchedule (Err _) ->
            ( model, Cmd.none )
