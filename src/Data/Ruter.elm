module Data.Ruter
    exposing
        ( Departure
        , stopDeparturesDecoder
        , getRelevantDepartures
        )

import Time.DateTime exposing (DateTime)
import Json.Decode as Decode


type alias DepartureTime =
    { aimed : DateTime
    , expected : DateTime
    }


type alias Departure =
    { lineColor : String
    , lineNumber : String
    , destination : String
    , platform : String
    , departure : DepartureTime
    }


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
        departurePlatformDecoder =
            Decode.field "DeparturePlatformName" Decode.string

        departureTimeDecoder =
            Decode.map2 DepartureTime
                (Decode.field "AimedDepartureTime" timeDecoder)
                (Decode.field "ExpectedDepartureTime" timeDecoder)

        departureListDecoder =
            Decode.map5 Departure
                (Decode.at [ "Extensions", "LineColour" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "PublishedLineName" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "DestinationName" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "MonitoredCall" ] departurePlatformDecoder)
                (Decode.at [ "MonitoredVehicleJourney", "MonitoredCall" ] departureTimeDecoder)
    in
        Decode.list departureListDecoder


getRelevantDepartures : List Departure -> List String -> List Departure
getRelevantDepartures departures excludedLines =
    departures
        |> List.filter (\d -> not (List.member d.destination excludedLines))
