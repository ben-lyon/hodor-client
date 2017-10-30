module Commands exposing (..)

import Http
import Json.Decode as Decode
import String exposing (append, split, join)

import Msgs exposing (..)
import Models exposing (MeetingRoom, ScheduledMeeting)

---- HTTP ----

getAvailability : (List MeetingRoom) -> Cmd Msg
getAvailability availability =
  let
    url =
      "http://localhost:8080/meetingRoom/lookup/all/availability"
  in
    Http.send LoadedAvailability (Http.get url availabilityListDecoder)

getRoomInfo : String -> Cmd Msg
getRoomInfo roomName =
    -- Encode the room name in url format. There's probably a better way to do this, but this was the most straightforward
    let
        url =
            append "http://localhost:8080/meetingRoom/lookup/" (split " " roomName |> join "%20")
    in
        Http.send LoadedRoomSchedule (Http.get url roomScheduleListDecoder)

---- JSON ----
availabilityDecoder : Decode.Decoder MeetingRoom
availabilityDecoder = Decode.map4 MeetingRoom (Decode.field "roomName" Decode.string) (Decode.field "available" Decode.bool) (Decode.field "nextAvailable" Decode.string) (Decode.field "nextMeeting" Decode.string)

availabilityListDecoder : Decode.Decoder (List MeetingRoom)
availabilityListDecoder = Decode.list availabilityDecoder

roomScheduleDecoder : Decode.Decoder ScheduledMeeting
roomScheduleDecoder = Decode.map3 ScheduledMeeting (Decode.field "email" Decode.string) (Decode.field "startDate" Decode.string) (Decode.field "endDate" Decode.string)

roomScheduleListDecoder : Decode.Decoder (List ScheduledMeeting)
roomScheduleListDecoder = Decode.list roomScheduleDecoder