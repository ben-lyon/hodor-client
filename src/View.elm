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
            homeView model
        Models.RoomRoute roomName ->
            roomView model
        Models.NotFoundRoute ->
            notFoundView


----- HOME PAGE -----

homeView : Model -> Html Msg
homeView model =
    div []
        [ headerView
        , conferenceRooms model.meetingRooms
        , wellnessRooms model.meetingRooms
        , aboutModal
        , footerView
        ]

headerView : Html Msg
headerView =
    Html.nav [class "navbar navbar-toggleable-md navbar-expand-lg navbar-light slalom-blue fixed-top"] [
        div [class "container"] [
           Html.button [class "navbar-toggler navbar-toggler-right", Html.Attributes.type_ "button", dataToggle "collapse", dataTarget "#navbarNav", ariaExpanded False, ariaControls "navbarNav"] [
               Html.span [class "navbar-toggler-icon fa-icon-color"][]
            ]
            ,Html.a [class "navbar-brand text-white", href "#first"] [
                Html.span [class "d-inline-block align-top fa fa-2x fa-address-book-o"] []
            ],
            div [class "collapse navbar-collapse", id "navbarNav"] [
            Html.ul [class "navbar-nav"]
            [
                Html.li [class "nav-item"] [
                    Html.a [class "nav-link text-white active", href "#"][text "Slalom-Hodor"]
                ],
                Html.li [class "nav-item"] [
                    Html.a [class "nav-link text-white active", href "#", dataToggle "modal", dataTarget "#Modal2"][text "about"]
                ]
            ]
            ]
        ]
    ]

conferenceRooms : List MeetingRoom -> Html Msg
conferenceRooms rooms =
    div []
        [ Html.h3 [class "conference-rooms"] [text "Conference Rooms"]
        , Html.hr [][]
        , listMeetingRooms (List.filter filterConferenceRooms rooms)
        ]

wellnessRooms : List MeetingRoom -> Html Msg
wellnessRooms rooms =
    div []
        [ Html.h3 [class "conference-rooms"] [text "Wellness Rooms"]
        , Html.hr [][]
        , listMeetingRooms (List.filter filterWellnessRooms rooms)
        ]

listMeetingRooms : List MeetingRoom -> Html Msg
listMeetingRooms rooms =
    let
        roomsView = List.map meetingRoomView ((List.filter openAndVacant rooms)++(List.filter openAndOccupied rooms)++(List.filter bookedAndVacant rooms)++(List.filter bookedAndOccupied rooms))
    in
        div [class "row room-container"]
            roomsView

meetingRoomView : MeetingRoom -> Html Msg
meetingRoomView room =
    div [class "col-sm-3"] [
        div [class (roomStatus room.available room.occupied)]
        [ div [class (roomHeader room.available room.occupied), onClick ( LoadRoomSchedule room.roomName )]
         [  Html.h4 [class "card-title"] [text room.roomName] ]
          ,div [class "card-block slalom-card-body"] [
              Html.h5 [class "card-title"] [text (getNextAvailMeetingString room), isOccupied room.occupied ]
            ]
        ]
    ]

roomHeader : Bool -> Bool -> String
roomHeader available occupied =
    case (available, occupied) of
        (True, False) ->
            "card-header slalom-card-header-open"
        (False, True) ->
            "card-header slalom-card-header-booked"
        (False, False) ->
            "card-header slalom-card-header-booked-vacant"
        (True, True) ->
            "card-header slalom-card-header-open-occupied"

aboutModal : Html Msg
aboutModal =
    div [class "modal fade", id "Modal2", tabIndex "-1", role "dialog", ariaHidden True]
    [ div [class "modal-dialog", role "document"]
        [ div [class "modal-content"]
            [ div [class "modal-header slalom-blue text-white"]
                [ Html.h5 [class "modal-title", id "ModalLabel"] [text "About Slalom-Hodor"]
                , Html.button [Html.Attributes.type_ "button", class "close", dataDismiss "modal", ariaLabel "Close"]
                    [ Html.span [class "fa fa-times fa-icon-color", ariaHidden True] [] ]
                ]
            , div [class "modal-body"]
                [roomLegend]
            , div [class "modal-footer slalom-blue"]
                [ Html.button [Html.Attributes.type_ "button", class "btn btn-info btn-md", dataDismiss "modal"] [text "Close"] ]
            ]
        ]
    ]

roomLegend : Html Msg
roomLegend =
    div [class "my-legend"]
        [ div [class "legend-title"] [text "Room Status Key Legend"]
        , div [class "legend-scale"]
            [Html.ul [class "legend-labels"]
                [ Html.li [] [Html.span [class "key-legend-open"][], text "Room is open in outlook and vacant"]
                , Html.li [] [Html.span [class "key-legend-open-occupied"][], text "Room is open in outlook but occupied"]
                , Html.li [] [Html.span [class "key-legend-booked-vacant"][], text "Room is booked in outlook but vacant"]
                , Html.li [] [Html.span [class "key-legend-booked"][], text "Room is booked in outlook and occupied"]
                ]
            ]
        , div [class "legend-source"] [text "Source: "
        , Html.a [href "https://bitbucket.org/account/user/meeting-rooms-hackathon/projects/MRA"] [text "source code here"]]
   ]

footerView : Html Msg
footerView =
    div [class "py-5 slalom-blue"]
        [ div [class "container"]
            [ Html.p [class "m-0 text-center text-white"] [text "Slalom-Hodor 2017"] ]
        ]


----- ROOM PAGE -----

roomView : Model -> Html Msg
roomView model =
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

----- 404 PAGE -----

notFoundView : Html Msg
notFoundView =
    div []
        [ text "Page not found" ]


----- HELPER METHODS -----

getNextAvailMeetingString : MeetingRoom -> String
getNextAvailMeetingString room =
    case room.available of
        True ->
            if String.isEmpty room.nextMeeting then
                " Open rest of day"
            else
                String.concat [" Booked at ", room.nextMeeting]
        False ->
            if String.isEmpty room.nextAvailable then
                " Booked rest of day"
            else
                String.concat [" Open at ", room.nextAvailable]


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


roomStatus : Bool -> Bool -> String
roomStatus available occupied =
    case (available, occupied) of
        (True, False) ->
            "card slalom-card-open"
        (False, True) ->
            "card slalom-card-booked"
        (True, True) ->
            "card slalom-card-open-occupied"
        (False, False) ->
            "card slalom-card-booked-vacant"

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

isOccupied : Bool -> Html Msg
isOccupied occupied =
    case occupied of
        False ->
            Html.br [] []
        True ->
            Html.span [class "fa fa-2x fa-users occupied"] []

calculateMeetingLength : Int -> String
calculateMeetingLength timeBlocks =
    append (toString (timeBlocks * 175)) "px"

calculateMeetingBlockColor : String -> String
calculateMeetingBlockColor meetingName =
    if meetingName == "Open" then
        "var(--NotBookedAndVacant)"
    else
        "var(--BookedAndOccupied)"


---- Filters ----
filterWellnessRooms : MeetingRoom -> Bool
filterWellnessRooms meetingRoom =
    String.startsWith "Wellness" meetingRoom.roomName

filterConferenceRooms : MeetingRoom -> Bool
filterConferenceRooms meetingRoom =
    not (String.startsWith "Wellness" meetingRoom.roomName)

openAndVacant : MeetingRoom -> Bool
openAndVacant meetingRoom =
    meetingRoom.available && not meetingRoom.occupied

bookedAndVacant : MeetingRoom -> Bool
bookedAndVacant meetingRoom =
    not meetingRoom.available && not meetingRoom.occupied

openAndOccupied : MeetingRoom -> Bool
openAndOccupied meetingRoom =
    meetingRoom.available && meetingRoom.occupied

bookedAndOccupied : MeetingRoom -> Bool
bookedAndOccupied meetingRoom =
    not meetingRoom.available && meetingRoom.occupied


---- Attributes ----
boolAttribute : String -> Bool -> Attribute msg
boolAttribute name val =
    attribute name (JE.encode 0 <| JE.bool val)

dataToggle : String -> Attribute Msg
dataToggle =
    attribute "data-toggle"

dataTarget : String -> Attribute Msg
dataTarget =
    attribute "data-target"

ariaHasPopUp : Bool -> Attribute Msg
ariaHasPopUp =
    boolAttribute "aria-haspopup"

ariaExpanded : Bool -> Attribute Msg
ariaExpanded =
    boolAttribute "aria-expanded"

ariaControls : String -> Attribute Msg
ariaControls =
    attribute "aria-controls"

ariaLabel : String -> Attribute Msg
ariaLabel =
    attribute "aria-label"

ariaHidden : Bool -> Attribute Msg
ariaHidden =
    boolAttribute "aria-hidden"

role : String -> Attribute Msg
role =
    attribute "role"

dataDismiss : String -> Attribute Msg
dataDismiss =
    attribute "data-dismiss"

tabIndex : String -> Attribute Msg
tabIndex =
    attribute "tabindex"
