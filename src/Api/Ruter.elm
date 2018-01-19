module Api.Ruter exposing (getStopDepartures)

import Http
import Task
import Time exposing (Time)
import Time.ZonedDateTime exposing (ZonedDateTime)
import Time.TimeZones exposing (europe_oslo)
import Data.Flags exposing (StopConfig)
import Data.Ruter exposing (Departure, stopDeparturesDecoder)
import Messages exposing (Msg(DeparturesReceived))


getStopDepartures : StopConfig -> Cmd Msg
getStopDepartures stopConfig =
    Time.now
        |> Task.andThen (\timestamp -> buildRequestWithTimestamp stopConfig timestamp)
        |> Task.attempt DeparturesReceived


buildRequestWithTimestamp : StopConfig -> Time -> Task.Task Http.Error (List Departure)
buildRequestWithTimestamp { stopId, timeToStop } now =
    let
        nowAsZonedDateTime =
            Time.ZonedDateTime.fromTimestamp (europe_oslo ()) now

        incrementedNowWithTimeToStop =
            (Time.ZonedDateTime.addMinutes timeToStop nowAsZonedDateTime)

        url =
            "http://reisapi.ruter.no/StopVisit/GetDepartures/"
                ++ (toString stopId)
                ++ "?datetime="
                ++ String.slice 0 16 (Time.ZonedDateTime.toISO8601 incrementedNowWithTimeToStop)
    in
        Http.get url stopDeparturesDecoder |> Http.toTask
