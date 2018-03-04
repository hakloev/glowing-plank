module View.Ruter exposing (view)

import Html exposing (Html, text, div, img, button, p, span, ul, li)
import Html.Attributes exposing (disabled, class, id, style)
import Time exposing (Time)
import Time.TimeZones exposing (europe_oslo)
import Time.DateTime exposing (DateTime)
import Time.ZonedDateTime exposing (ZonedDateTime)
import Messages exposing (Msg(..))
import Data.Ruter exposing (Departure)


view : ( List Departure, List Departure ) -> Time -> Html Msg
view departures now =
    renderDepartures departures now


isAfterNow : DateTime -> Time -> Bool
isAfterNow departureTime now =
    let
        nowAsDateTime =
            Time.DateTime.fromTimestamp now
    in
        case Time.DateTime.compare departureTime nowAsDateTime of
            GT ->
                True

            _ ->
                False


renderDepartures : ( List Departure, List Departure ) -> Time -> Html Msg
renderDepartures ( westboundDepartures, eastboundDepartures ) now =
    div [ id "departures" ]
        [ case westboundDepartures of
            [] ->
                text ""

            _ ->
                ul [ class "departure-list" ]
                    (westboundDepartures
                        |> List.filter (\d -> isAfterNow d.departure now)
                        |> List.take 3
                        |> List.map (\d -> renderDeparture d now)
                    )
        , case eastboundDepartures of
            [] ->
                text ""

            _ ->
                ul [ class "departure-list" ]
                    (eastboundDepartures
                        |> List.filter (\d -> isAfterNow d.departure now)
                        |> List.take 3
                        |> List.map (\d -> renderDeparture d now)
                    )
        ]


printDepartureTime : DateTime -> Time -> String
printDepartureTime departureTime now =
    let
        deltaBetween =
            Time.DateTime.delta departureTime (Time.DateTime.fromTimestamp now)

        minutesUntilDeparture =
            deltaBetween.minutes

        departureInLocalTime =
            Time.ZonedDateTime.fromDateTime (europe_oslo ()) departureTime

        timeToPrint =
            if minutesUntilDeparture == 0 then
                "nå"
            else if minutesUntilDeparture < 15 then
                (toString minutesUntilDeparture) ++ " " ++ "min"
            else
                (Time.ZonedDateTime.hour departureInLocalTime |> toString |> String.padLeft 2 '0')
                    ++ ":"
                    ++ (Time.ZonedDateTime.minute departureInLocalTime |> toString |> String.padLeft 2 '0')

        -- _ =
        --     Debug.log "between" (toString deltaBetween.minutes)
    in
        timeToPrint


renderDeparture : Departure -> Time -> Html Msg
renderDeparture departure now =
    li [ class "departure-list-item" ]
        [ div [ class "departure-line-number" ] [ text departure.lineNumber ]
        , div [ class "departure-line-title" ] [ text departure.destinationName ]
        , div [ class "departure-time" ] [ text (printDepartureTime departure.departure now) ]
        ]
