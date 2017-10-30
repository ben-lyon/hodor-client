module Models exposing (..)

type alias Model =
    {
        meetingRooms : List MeetingRoom,
        route: Route
    }
type alias MeetingRoom =
    {
        roomName : String,
        available : Bool,
        nextAvailable: String,
        nextMeeting: String
    }

type RoomState = BookedAndOccupied | BookedAndVacant | NotBookedAndOccupied | NotBookedAndVacant

type Route
    = HomeRoute
    | RoomRoute String
    | NotFoundRoute