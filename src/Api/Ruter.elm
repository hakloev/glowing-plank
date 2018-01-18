module Api.Ruter exposing (getStopDepartures)

import Http
import Task
import Time exposing (Time)
import Time.ZonedDateTime exposing (ZonedDateTime)
import Time.TimeZones exposing (europe_oslo)
import Data.Flags exposing (RuterStop)
import Data.Ruter exposing (Departure, DepartureTime, stopDeparturesDecoder)
import Messages exposing (Msg(DeparturesReceived))


getStopDepartures : RuterStop -> Cmd Msg
getStopDepartures stop =
    Time.now
        |> Task.andThen (\timestamp -> buildRequest stop timestamp)
        |> Task.attempt DeparturesReceived


buildRequest : RuterStop -> Time -> Task.Task Http.Error (List Departure)
buildRequest { stopId, timeToStop } now =
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
