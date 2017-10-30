module Update exposing (..)

-- Tmp
import Debug exposing (log)

import Msgs exposing (..)
import Models exposing (..)
import Routing exposing (parseLocation)
import Commands exposing (getAvailability)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadAvailability ->
            (model, getAvailability model.meetingRooms)
        LoadedAvailability (Ok meetingRooms) ->
            ( Model meetingRooms HomeRoute, Cmd.none )
        LoadedAvailability (Err _) ->
            ( model, Cmd.none )
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )
        ShowRoomInfo roomName ->
            ( { model | route = RoomRoute roomName }, Cmd.none )
        Test ->
            log "test"
            ( model, Cmd.none )