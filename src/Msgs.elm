module Msgs exposing (..)

import Http
import Navigation exposing (Location)

import Models exposing (MeetingRoom)

type Msg
    = LoadAvailability
    | LoadedAvailability (Result Http.Error (List MeetingRoom))
    | Test
    | ShowRoomInfo String
    | OnLocationChange Location