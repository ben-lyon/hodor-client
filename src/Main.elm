module Main exposing (..)

import Html exposing (Html, Attribute, text, div, img, a, button)
import Html.Attributes exposing (..)
import Json.Encode as JE
import Http
import Json.Decode as Decode
import String


---- MODEL ----


type alias Model =
    {
        meetingRooms : List MeetingRoom
    }
type alias MeetingRoom = 
    {
        roomName : String,
        available : Bool,
        nextAvailable: String,
        nextMeeting: String
    }

type RoomState = BookedAndOccupied | BookedAndVacant | NotBookedAndOccupied | NotBookedAndVacant

init : (List MeetingRoom) -> ( Model, Cmd Msg )
init meetingRooms =
    ( Model meetingRooms, getAvailability meetingRooms )



---- UPDATE ----


type Msg
    = LoadAvailability
    | LoadedAvailability (Result Http.Error (List MeetingRoom))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadAvailability ->
            (model, getAvailability model.meetingRooms)
        LoadedAvailability (Ok meetingRooms) ->
            ( Model meetingRooms, Cmd.none )
        LoadedAvailability (Err _) ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ headerView
        , timeSearchView
        , listMeetingRooms model.meetingRooms
        , footerView
        ]

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

meetingRoomView : MeetingRoom -> Html Msg
meetingRoomView room =
    div [class "col-sm-6"] [
        div [class (roomStatus room.available)] 
        [ div [class "card-body"] 
            [ Html.h4 [class "card-title"] [text room.roomName],
              Html.h5 [class "card-title"] [text (getNextAvailMeetingString room.available room.nextAvailable room.nextMeeting)]
            ]
        ]
    ]

getNextAvailMeetingString : Bool -> String -> String -> String
getNextAvailMeetingString available nextAvailable nextMeeting =
    case available of
        True ->
            String.concat ["Booked: ", nextMeeting]
        False ->
            String.concat ["Open: ", nextAvailable]

listMeetingRooms : List MeetingRoom -> Html Msg
listMeetingRooms rooms =
    let
        roomsView = List.map meetingRoomView rooms
    in
        div [class "row"]
            roomsView

headerView : Html Msg
headerView = 
    div [class "navbar navbar-expand-lg navbar-dark bg-dark fixed-top"] [
        div [class "container"] [
            Html.a [class "navbar-brand", href "#"] [text "Hodor"]
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


---- HTTP ----

getAvailability : (List MeetingRoom) -> Cmd Msg
getAvailability availability =
  let
    url =
      "http://localhost:8080/meetingRoom/lookup/all/availability"
  in
    Http.send LoadedAvailability (Http.get url availabilityListDecoder)

---- JSON ----
availabilityDecoder : Decode.Decoder MeetingRoom
availabilityDecoder = Decode.map4 MeetingRoom (Decode.field "roomName" Decode.string) (Decode.field "available" Decode.bool) (Decode.field "nextAvailable" Decode.string) (Decode.field "nextMeeting" Decode.string)

availabilityListDecoder : Decode.Decoder (List MeetingRoom)
availabilityListDecoder = Decode.list availabilityDecoder

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
---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init []
        , update = update
        , subscriptions = always Sub.none
        }
