module Msgs exposing (..)

import Http
import Navigation exposing (Location)

import Models exposing (MeetingRoom, ScheduledMeeting)

type Msg
    = LoadAvailability
    | LoadedAvailability (Result Http.Error (List MeetingRoom))
    | LoadRoomSchedule String
    | LoadedRoomSchedule (Result Http.Error (List ScheduledMeeting))
    | OnLocationChange Location