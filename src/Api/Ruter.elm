module Api.Ruter exposing (..)

import Http
import Json.Decode as Decode
import Data.Ruter exposing (Departure, DepartureTime)
import Messages exposing (Msg(GetStopDepartures))


getStopDepartures : Int -> Cmd Msg
getStopDepartures stopId =
    let
        url =
            -- TODO: Add support for datetime and timeToStop
            "http://reisapi.ruter.no/StopVisit/GetDepartures/" ++ (toString 3012120)

        request =
            Http.get url stopDeparturesDecoder
    in
        Http.send GetStopDepartures request


stopDeparturesDecoder : Decode.Decoder (List Departure)
stopDeparturesDecoder =
    let
        departureTimeDecoder =
            Decode.map2 DepartureTime
                (Decode.field "AimedDepartureTime" Decode.string)
                (Decode.field "ExpectedDepartureTime" Decode.string)

        departureListDecoder =
            Decode.map4 Departure
                (Decode.at [ "Extensions", "LineColour" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "PublishedLineName" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "DestinationName" ] Decode.string)
                (Decode.at [ "MonitoredVehicleJourney", "MonitoredCall" ] departureTimeDecoder)
    in
        Decode.list departureListDecoder
