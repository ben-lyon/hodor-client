module Msgs exposing (..)

import Http
import Navigation exposing (Location)
import Time exposing (..)

import Models exposing (MeetingRoom, ScheduledMeeting, RoomSchedule)

type Msg
    = LoadAvailability
    | LoadedAvailability (Result Http.Error (List MeetingRoom))
    | LoadRoomSchedule String
    | LoadedRoomSchedule (Result Http.Error RoomSchedule)
    | OnLocationChange Location
    | OnTime Time
    | ReloadRoomSchedule Time