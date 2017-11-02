module Subscriptions exposing (..)

import Time exposing (..)

import Models exposing (Model)
import Msgs exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.autoUpdate then
        Sub.batch
        [ Time.every Time.minute OnTime
        , Time.every (Time.minute * 10) ReloadRoomSchedule
        ]
    else
        Sub.none