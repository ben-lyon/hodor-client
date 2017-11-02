module View exposing (..)

import Css exposing (asPairs, margin, pct, border3, rgb, px, solid, padding)
import Date exposing (..)
import Html exposing (Html, Attribute, text, div, img, a, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import String exposing (append, slice)

import Models exposing (..)
import Msgs exposing (..)
import Json.Encode as JE

styles : List Css.Style  -> Attribute msg
styles =
    Css.asPairs >> Html.Attributes.style


view : Model -> Html Msg
view model =
    div []
        [ page model ]

page : Model -> Html Msg
page model =
    case model.route of
        Models.HomeRoute ->
            homePage model
        Models.RoomRoute roomName ->
            roomPage model
        Models.NotFoundRoute ->
            notFoundPage

homePage : Model -> Html Msg
homePage model =
    div []
        [ headerView "Hodor"
        , keyView
        , listMeetingRooms model.meetingRooms
        , footerView
        ]

roomPage : Model -> Html Msg
roomPage model =
    div []
        [ roomHeaderView model.roomSchedule.meetingRoom
        , currentTimeView model.time
        , listScheduledMeetings model.roomSchedule.meetings
        , Html.h4 [class "next-avail"] [text (getNextAvailMeetingString model.roomSchedule.meetingRoom) ]
        ]

roomHeaderView : MeetingRoom -> Html Msg
roomHeaderView roomInfo =
    div [class "room-header", style [("color", (roomInfo.available |> deriveRoomStateSimple |> deriveRoomStateColor))]]
        [ text roomInfo.roomName ]

currentTimeView : Float -> Html Msg
currentTimeView time =
    div [class "clock"]
        [ time |> Date.fromTime |> toString |> (slice 17 22) |> text ]

listScheduledMeetings : List ScheduledMeeting -> Html Msg
listScheduledMeetings meetingData =
    let
        meetingsView = List.map scheduledMeetingView meetingData
    in
        div [class "room-timeline"]
            meetingsView

scheduledMeetingView : ScheduledMeeting -> Html Msg
scheduledMeetingView meeting =
    div [class "meeting-block", style [("width", calculateMeetingLength meeting.timeBlocks), ("background-color", calculateMeetingBlockColor meeting.organizerName)] ]
        [ Html.h6 [] [text meeting.organizerName]
        , Html.h6 [] [text meeting.timeRange]
        ]

notFoundPage : Html Msg
notFoundPage =
    div []
        [ text "Page not found" ]

timeSearchView : Html Msg
timeSearchView =
    div [class "row"] [
        div [class "btn-group ml-2 time-dropdown"] [
            button [type_ "button", class "btn btn-lg btn-secondary"] [text "Select Time"]
            , button [type_ "button", class "btn btn-lg btn-secondary dropdown-toggle dropdown-toggle-split", dataToggle "dropdown", ariaHasPopUp True, ariaExpanded False] [Html.span [class "sr-only"] [text "Toggle Dropdown"]]
            , div [class "dropdown-menu"] [
                a [class "dropdown-item", href "#"] [text "11:30AM"]
                , a [class "dropdown-item", href "#"] [text "12:00PM"]
                , a [class "dropdown-item", href "#"] [text "12:30PM"]
            ]
        ]
    ]

keyView : Html Msg
keyView =
    div [class "row"] [
        div [class "col-sm-3"] [
            div [class "room-card room-state-not-booked"]
            [ div [class "card-body"]
                [ Html.h4 [class "card-title"] [text "Open and Empty"]
                ]
            ]
        ],

        div [class "col-sm-3"] [
            div [class "room-card room-state-not-booked-occupied"]
            [ div [class "card-body"]
                [ Html.h4 [class "card-title"] [text "Open and Occupied"]
                ]
            ]
        ],

        div [class "col-sm-3"] [
            div [class "room-card room-state-booked-not-occupied"]
            [ div [class "card-body"]
                [ Html.h4 [class "card-title"] [text "Booked and Empty"]
                ]
            ]
        ],

        div [class "col-sm-3"] [
            div [class "room-card room-state-booked"]
            [ div [class "card-body"]
                [ Html.h4 [class "card-title"] [text "Booked, Occupied"]
                ]
            ]
        ]
    ]

meetingRoomView : MeetingRoom -> Html Msg
meetingRoomView room =
    div [class "col-sm-3"] [
        div [class (roomStatus room.available)]
        [ div [class "card-body", onClick ( LoadRoomSchedule room.roomName )]
            [ Html.h4 [class "card-title"] [text room.roomName],
              Html.h5 [class "card-title"] [text (getNextAvailMeetingString room)]
            ]
        ]
    ]

getNextAvailMeetingString : MeetingRoom -> String
getNextAvailMeetingString room =
    case room.available of
        True ->
            String.concat ["Booked at ", room.nextMeeting]
        False ->
            String.concat ["Open at ", room.nextAvailable]

listMeetingRooms : List MeetingRoom -> Html Msg
listMeetingRooms rooms =
    let
        roomsView = List.map meetingRoomView rooms
    in
        div [class "row"]
            roomsView

headerView : String -> Html Msg
headerView pageName =
    div [class "navbar navbar-expand-lg navbar-dark bg-dark fixed-top"] [
        div [class "container"] [
            Html.a [class "navbar-brand", href "#"] [text pageName]
        ]
    ]

footerView : Html Msg
footerView =
    div [class "py-5 bg-dark"]
        [ div [class "container"]
            [
                Html.p [class "m-0 text-center text-white"] [text "Hodor 2017"]
            ]
        ]

-- Temporary method that doesn't take into account whether or not a room is occupied since we don't have access to that data currently
deriveRoomStateSimple : Bool -> RoomState
deriveRoomStateSimple available =
    case available of
        True -> NotBookedAndVacant
        False -> BookedAndOccupied

deriveRoomState : Bool -> Bool -> RoomState
deriveRoomState booked occupied =
    case booked of
        True ->
            case occupied of
                True -> BookedAndOccupied
                False -> BookedAndVacant
        False ->
            case occupied of
                True -> NotBookedAndOccupied
                False -> NotBookedAndVacant

deriveRoomStateColor : RoomState -> String
deriveRoomStateColor state =
    case state of
        BookedAndOccupied -> "var(--BookedAndOccupied)"
        BookedAndVacant -> "var(--BookedAndVacant)"
        NotBookedAndOccupied -> "var(--NotBookedAndOccupied)"
        NotBookedAndVacant -> "var(--NotBookedAndVacant)"


roomStatus : Bool -> String
roomStatus status =
    case status of
        False ->
            "room-card room-state-booked"
        True ->
            "room-card room-state-not-booked"

roomStatusDescription : RoomState -> String
roomStatusDescription status =
    case status of
        BookedAndOccupied ->
            "Unavailable"
        BookedAndVacant ->
            "Booked but empty"
        NotBookedAndVacant ->
            "Available"
        NotBookedAndOccupied ->
            "Available but occupied"

calculateMeetingLength : Int -> String
calculateMeetingLength timeBlocks =
    append (toString (timeBlocks * 175)) "px"

calculateMeetingBlockColor : String -> String
calculateMeetingBlockColor meetingName =
    if meetingName == "Open" then
        "#86E965"
    else
        "#ef7777"


---- Attributes ----
boolAttribute : String -> Bool -> Attribute msg
boolAttribute name val =
    attribute name (JE.encode 0 <| JE.bool val)

dataToggle : String -> Attribute Msg
dataToggle =
    attribute "data-toggle"


ariaHasPopUp : Bool -> Attribute Msg
ariaHasPopUp =
    boolAttribute "aria-haspopup"

ariaExpanded : Bool -> Attribute Msg
ariaExpanded =
    boolAttribute "aria-expanded"
