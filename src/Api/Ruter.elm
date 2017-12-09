module Api.Ruter exposing (getStopDepartures)

import Http
import Time.DateTime exposing (DateTime)
import Time.ZonedDateTime exposing (ZonedDateTime)
import Time.TimeZones exposing (europe_oslo)
import Data.Flags exposing (RuterStop)
import Data.Ruter exposing (Departure, DepartureTime, stopDeparturesDecoder)
import Messages exposing (Msg(GetStopDepartures))


getStopDepartures : RuterStop -> DateTime -> Cmd Msg
getStopDepartures stop now =
    let
        nowAsZonedDateTime =
            Time.ZonedDateTime.fromDateTime (europe_oslo ()) now

        incrementedNowWithTimeToStop =
            (Time.ZonedDateTime.addMinutes stop.timeToStop nowAsZonedDateTime)

        url =
            "http://reisapi.ruter.no/StopVisit/GetDepartures/"
                ++ (toString stop.stopId)
                ++ "?datetime="
                ++ String.slice 0 16 (Time.ZonedDateTime.toISO8601 incrementedNowWithTimeToStop)

        request =
            Http.get url stopDeparturesDecoder
    in
        Http.send GetStopDepartures request
