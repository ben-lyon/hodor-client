module Update exposing (..)

import Msgs exposing (..)
import Models exposing (..)
import Routing exposing (parseLocation)
import Commands exposing (getAvailability, getRoomInfo, getTime)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadAvailability ->
            (model, getAvailability model.meetingRooms)
        LoadedAvailability (Ok meetingRooms) ->
            ( Model meetingRooms "" [] HomeRoute False 0, Cmd.none )
        LoadedAvailability (Err _) ->
            ( model, Cmd.none )
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )
        LoadRoomSchedule roomName ->
            ( { model | roomName = roomName, route = RoomRoute roomName, autoUpdate = True}, getRoomInfo roomName )
        LoadedRoomSchedule (Ok roomSchedule) ->
            ( { model | roomSchedule = roomSchedule }, getTime )
        LoadedRoomSchedule (Err _) ->
            ( model, Cmd.none )
        OnTime t ->
            ( { model | time = t }, Cmd.none )
        ReloadRoomSchedule t ->
            ( { model | time = t }, getRoomInfo model.roomName )
