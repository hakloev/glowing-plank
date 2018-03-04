module Data.Ruter
    exposing
        ( Departure
        , stopDeparturesDecoder
        , getRelevantDepartures
        )

import Time.DateTime exposing (DateTime)
import Json.Decode as Decode


type DirectionReference
    = NoDirection
    | Westbound
    | Eastbound


type alias Departure =
    { lineNumber : String
    , destinationName : String
    , departure : DateTime
    , direction : DirectionReference
    }


departureTimeDecoder : Decode.Decoder DateTime
departureTimeDecoder =
    Decode.string
        |> Decode.andThen
            (\timestamp ->
                case Time.DateTime.fromISO8601 timestamp of
                    Ok ok ->
                        Decode.succeed ok

                    Err err ->
                        Decode.fail err
            )


decodeDirectionReference : Decode.Decoder DirectionReference
decodeDirectionReference =
    Decode.field "DirectionRef" <|
        Decode.oneOf
            [ Decode.null NoDirection
            , Decode.string
                |> Decode.andThen
                    (\directionRef ->
                        case directionRef of
                            "1" ->
                                Decode.succeed Westbound

                            "2" ->
                                Decode.succeed Eastbound

                            _ ->
                                Decode.fail <| "Unrecognized DirectionRef " ++ directionRef
                    )
            ]


stopDeparturesDecoder : Decode.Decoder (List Departure)
stopDeparturesDecoder =
    let
        departureListDecoder =
            Decode.map4 Departure
                (Decode.at [ "MonitoredVehicleJourney", "PublishedLineName" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "DestinationName" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "MonitoredCall" ] <|
                    Decode.field "ExpectedDepartureTime" departureTimeDecoder
                )
                (Decode.at [ "MonitoredVehicleJourney" ] decodeDirectionReference)
    in
        Decode.list departureListDecoder


getRelevantDepartures : List Departure -> List String -> ( List Departure, List Departure )
getRelevantDepartures departures excludedLines =
    departures
        |> List.filter (\d -> not (List.member d.destinationName excludedLines))
        |> List.filter (\d -> d.direction /= NoDirection)
        |> List.partition (\d -> d.direction == Westbound)
