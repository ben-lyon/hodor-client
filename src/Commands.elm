module Commands exposing (..)

import Http
import Json.Decode as Decode
import String exposing (concat, split, join)
import Task exposing (perform)
import Time exposing (now)

import Msgs exposing (..)
import Models exposing (MeetingRoom, ScheduledMeeting, RoomSchedule)

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
            concat ["http://localhost:8080/meetingRoom/lookup/", (split " " roomName |> join "%20"), "/schedule"]
    in
        Http.send LoadedRoomSchedule (Http.get url roomScheduleDecoder)

---- JSON ----
availabilityDecoder : Decode.Decoder MeetingRoom
availabilityDecoder = Decode.map5 MeetingRoom (Decode.field "roomName" Decode.string) (Decode.field "available" Decode.bool) (Decode.field "nextAvailable" Decode.string) (Decode.field "nextMeeting" Decode.string) (Decode.field "occupied" Decode.bool)

availabilityListDecoder : Decode.Decoder (List MeetingRoom)
availabilityListDecoder = Decode.list availabilityDecoder

roomScheduleDecoder : Decode.Decoder RoomSchedule
roomScheduleDecoder = Decode.map2 RoomSchedule (Decode.field "currentAvailability" availabilityDecoder) (Decode.field "schedule" scheduledMeetingListDecoder)

scheduledMeetingDecoder : Decode.Decoder ScheduledMeeting
scheduledMeetingDecoder = Decode.map3 ScheduledMeeting (Decode.field "organizerName" Decode.string) (Decode.field "timeBlocks" Decode.int) (Decode.field "timeRange" Decode.string)

scheduledMeetingListDecoder : Decode.Decoder (List ScheduledMeeting)
scheduledMeetingListDecoder = Decode.list scheduledMeetingDecoder


---- Clock update ----
getTime : Cmd Msg
getTime = Time.now |> Task.perform OnTime