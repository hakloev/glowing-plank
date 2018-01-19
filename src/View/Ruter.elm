module View.Ruter exposing (view)

import Html exposing (Html, text, div, img, button, p, span, ul, li)
import Html.Attributes exposing (disabled, class, id, style)
import Time exposing (Time)
import Time.TimeZones exposing (europe_oslo)
import Time.DateTime exposing (DateTime)
import Time.ZonedDateTime exposing (ZonedDateTime)
import Messages exposing (Msg(..))
import Data.Ruter exposing (Departure)


view : List Departure -> Time -> Html Msg
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


renderDepartures : List Departure -> Time -> Html Msg
renderDepartures departures now =
    div [ id "departures" ]
        [ case departures of
            [] ->
                text ""

            _ ->
                ul [ id "departure-list" ]
                    (departures
                        |> List.filter (\d -> isAfterNow d.departure.expected now)
                        |> List.take 10
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
    let
        lineStyle =
            style [ ( "background-color", "#" ++ departure.lineColor ) ]
    in
        li [ class "departure-list-item" ]
            [ div [ class "departure-line-number", lineStyle ] [ text departure.lineNumber ]
            , div [ class "departure-line-title" ] [ text departure.destination ]
            , div [ class "departure-time" ] [ text (printDepartureTime departure.departure.expected now) ]
            ]
