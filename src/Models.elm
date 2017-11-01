module Models exposing (..)

type alias Model =
    {
        meetingRooms : List MeetingRoom,
        roomName : String,
        roomSchedule : List ScheduledMeeting,
        route: Route,
        autoUpdate: Bool,
        time: Float
    }
type alias MeetingRoom =
    {
        roomName : String,
        available : Bool,
        nextAvailable: String,
        nextMeeting: String
    }
type alias ScheduledMeeting =
    {
        organizerName: String,
        timeBlocks: Int,
        timeRange: String
    }

type RoomState = BookedAndOccupied | BookedAndVacant | NotBookedAndOccupied | NotBookedAndVacant

type Route
    = HomeRoute
    | RoomRoute String
    | NotFoundRoute