module Models exposing (..)

type alias Model =
    {
        meetingRooms : List MeetingRoom,
        roomSchedule : RoomSchedule,
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
type alias RoomSchedule =
    {
        meetingRoom : MeetingRoom,
        meetings : List ScheduledMeeting
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