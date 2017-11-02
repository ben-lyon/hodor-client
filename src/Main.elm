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
        nextMeeting: String,
        occupied: Bool
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
        , conferenceRooms model.meetingRooms
        , wellnessRooms model.meetingRooms
        , aboutModal
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

keyView : Html Msg
keyView =
    div [class "row bottom"] [
        div [class "col-sm-3"] [
            div [class "key-card room-state-not-booked"]
            [ div [class "card-body"]
                [ Html.h5 [class "card-title"] [text "Open and Empty"]
                ]
            ]
        ],

        div [class "col-sm-3"] [
            div [class "key-card room-state-not-booked-occupied"]
            [ div [class "card-body"]
                [ Html.h5 [class "card-title"] [text "Open and Occupied"]
                ]
            ]
        ],

        div [class "col-sm-3"] [
            div [class "key-card room-state-booked-not-occupied"]
            [ div [class "card-body"]
                [ Html.h5 [class "card-title"] [text "Booked and Empty"]
                ]
            ]
        ],

        div [class "col-sm-3"] [
            div [class "key-card room-state-booked"]
            [ div [class "card-body"]
                [ Html.h5 [class "card-title"] [text "Booked, Occupied"]
                ]
            ]
        ]
    ]

meetingRoomView : MeetingRoom -> Html Msg
meetingRoomView room =
    div [class "col-sm-3"] [
        div [class (roomStatus room.available room.occupied)] 
        [ div [class (roomHeader room.available room.occupied)] 
         [  Html.h4 [class "card-title"] [text room.roomName] ]
          ,div [class "card-block slalom-card-body"] [
              Html.h5 [class "card-title"] [text (getNextAvailMeetingString room.available room.nextAvailable room.nextMeeting), isOccupied room.occupied ]
            ]
        ]
        ]

getNextAvailMeetingString : Bool -> String -> String -> String
getNextAvailMeetingString available nextAvailable nextMeeting =
    case available of
        True ->
            if String.isEmpty nextMeeting then
                " Open rest of day"
            else 
                String.concat [" Booked at ", nextMeeting]
        False ->
            if String.isEmpty nextAvailable then
                " Booked rest of day"
            else
                String.concat [" Open at ", nextAvailable]

listMeetingRooms : List MeetingRoom -> Html Msg
listMeetingRooms rooms =
    let
        roomsView = List.map meetingRoomView ((List.filter openAndVacant rooms)++(List.filter openAndOccupied rooms)++(List.filter bookedAndVacant rooms)++(List.filter bookedAndOccupied rooms))
    in
        div [class "row room-container"]
            roomsView

conferenceRooms : List MeetingRoom -> Html Msg
conferenceRooms rooms =
    div [] 
        [ Html.h3 [class "conference-rooms"] [text "Conference Rooms"]
        , Html.hr [][]
        , listMeetingRooms (List.filter filterConfernceRooms rooms)
        ]
wellnessRooms : List MeetingRoom -> Html Msg
wellnessRooms rooms =
    div [] 
        [ Html.h3 [class "conference-rooms"] [text "Wellness Rooms"]
        , Html.hr [][]
        , listMeetingRooms (List.filter filterWellnessRooms rooms)
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

legendView : Html Msg
legendView =
    div [class "row"] [
        div [class "key-legend"] [
            Html.p [] [text "open and empty"],
            Html.p [] [text "open and occupied"]
        ]
    ] 

footerView : Html Msg
footerView =
    div [class "py-5 slalom-blue"]
        [ div [class "container"] [
            Html.p [class "m-0 text-center text-white"] [text "Slalom-Hodor 2017"]
        ]
        ]

aboutModal : Html Msg
aboutModal =
    div [class "modal fade", id "Modal2", tabIndex "-1", role "dialog", ariaHidden True]
    [ div [class "modal-dialog", role "document"]
        [ div [class "modal-content"]
            [div [class "modal-header slalom-blue text-white"]
                [ Html.h5 [class "modal-title", id "ModalLabel"] [text "About Slalom-Hodor"]
                , Html.button [Html.Attributes.type_ "button", class "close", dataDismiss "modal", ariaLabel "Close"] 
                    [ Html.span [class "fa fa-times fa-icon-color", ariaHidden True] []
                    ]
            ]
       , div [class "modal-body"]
            [roomLegend]
       , div [class "modal-footer slalom-blue"][
            Html.button [Html.Attributes.type_ "button", class "btn btn-info btn-md", dataDismiss "modal"] [text "Close"]
       ]

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
        ,div [class "legend-source"] [text "Source: "
        , Html.a [href "https://bitbucket.org/account/user/meeting-rooms-hackathon/projects/MRA"] [text "source code here"]]
   ]
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

isOccupied : Bool -> Html Msg
isOccupied occupied =
    case occupied of 
        False ->
            Html.br [] []
        True ->
            Html.span [class "fa fa-2x fa-users occupied"] []

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
      --"http://localhost:8080/meetingRoom/lookup/all/availability"
      "http://hodorserver-env.us-east-1.elasticbeanstalk.com/meetingRoom/lookup/all/availability"
  in
    Http.send LoadedAvailability (Http.get url availabilityListDecoder)

---- JSON ----
availabilityDecoder : Decode.Decoder MeetingRoom
availabilityDecoder = Decode.map5 MeetingRoom (Decode.field "roomName" Decode.string) (Decode.field "available" Decode.bool) (Decode.field "nextAvailable" Decode.string) (Decode.field "nextMeeting" Decode.string) (Decode.field "occupied" Decode.bool)

availabilityListDecoder : Decode.Decoder (List MeetingRoom)
availabilityListDecoder = Decode.list availabilityDecoder

---- Filters ----
filterWellnessRooms : MeetingRoom -> Bool
filterWellnessRooms meetingRoom =
    String.startsWith "Wellness" meetingRoom.roomName

filterConfernceRooms : MeetingRoom -> Bool
filterConfernceRooms meetingRoom =
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
---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init []
        , update = update
        , subscriptions = always Sub.none
        }
