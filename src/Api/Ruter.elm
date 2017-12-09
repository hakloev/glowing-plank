module Api.Ruter exposing (..)

import Http
import Json.Decode as Decode
import Time
import Time.DateTime exposing (DateTime)
import Time.ZonedDateTime exposing (ZonedDateTime)
import Time.TimeZones exposing (europe_oslo)
import Data.Ruter exposing (Departure, DepartureTime)
import Messages exposing (Msg(GetStopDepartures))


getStopDepartures : Int -> Time.Time -> Cmd Msg
getStopDepartures stopId now =
    let
        nowAsDateTime =
            Time.ZonedDateTime.fromTimestamp (europe_oslo ()) now

        incrementedNowWithTimeToStop =
            (Time.ZonedDateTime.addMinutes 1 nowAsDateTime)

        url =
            -- TODO: Add support for datetime and timeToStop
            "http://reisapi.ruter.no/StopVisit/GetDepartures/"
                ++ (toString 3012120)
                ++ "?datetime="
                ++ String.slice 0 16 (Time.ZonedDateTime.toISO8601 incrementedNowWithTimeToStop)

        request =
            Http.get url stopDeparturesDecoder
    in
        Http.send GetStopDepartures request


timeDecoder : Decode.Decoder DateTime
timeDecoder =
    Decode.string
        |> Decode.andThen
            (\timestamp ->
                case Time.DateTime.fromISO8601 timestamp of
                    Ok ok ->
                        Decode.succeed ok

                    Err err ->
                        Decode.fail err
            )


stopDeparturesDecoder : Decode.Decoder (List Departure)
stopDeparturesDecoder =
    let
        departureTimeDecoder =
            Decode.map2 DepartureTime
                (Decode.field "AimedDepartureTime" timeDecoder)
                (Decode.field "ExpectedDepartureTime" timeDecoder)

        departureListDecoder =
            Decode.map4 Departure
                (Decode.at [ "Extensions", "LineColour" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "PublishedLineName" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "DestinationName" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "MonitoredCall" ] departureTimeDecoder)
    in
        Decode.list departureListDecoder
