module View exposing (..)

import Html exposing (Html, Attribute, text, div, img, a, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import String exposing (append)

import Models exposing (..)
import Msgs exposing (..)
import Json.Encode as JE


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
            roomPage model roomName
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

roomPage : Model -> String -> Html Msg
roomPage model roomName =
    div []
        [ headerView roomName
        , listScheduledMeetings model.roomSchedule
        ]

listScheduledMeetings : List ScheduledMeeting -> Html Msg
listScheduledMeetings meetingData =
    let
        meetingsView = List.map scheduledMeetingView meetingData
    in
        div [class "row"]
            meetingsView

scheduledMeetingView : ScheduledMeeting -> Html Msg
scheduledMeetingView meeting =
    div [class "col-sm-3"]
        [ div [class "card-body"]
            [ Html.h5 [] [text meeting.email]
            , Html.h5 [] [text meeting.startDate]
            , Html.h5 [] [text meeting.endDate]
            ]
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
              Html.h5 [class "card-title"] [text (getNextAvailMeetingString room.available room.nextAvailable room.nextMeeting)]
            ]
        ]
    ]

getNextAvailMeetingString : Bool -> String -> String -> String
getNextAvailMeetingString available nextAvailable nextMeeting =
    case available of
        True ->
            String.concat ["Booked at ", nextMeeting]
        False ->
            String.concat ["Open at ", nextAvailable]

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
        [ div [class "container"] [
            Html.p [class "m-0 text-center text-white"] [text "Hodor 2017"]
        ]
        ]

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
