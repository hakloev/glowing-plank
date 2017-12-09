module Main exposing (..)

import Task
import Html exposing (Html, text, div, img, button, p, span)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Time exposing (Time)
import Time.TimeZones exposing (europe_oslo)
import Time.DateTime exposing (DateTime)
import Time.ZonedDateTime exposing (ZonedDateTime)
import Json.Decode as Decode
import Messages exposing (Msg(..))
import Model exposing (Model)
import Data.Flags exposing (ruterConfigDecoder, Flags)
import Data.Lights exposing (isAnyLightActive)
import Data.Ruter exposing (Departure)
import Api.Lights exposing (getLightStatus, turnOffLightsInSequence)
import Api.Ruter exposing (getStopDepartures)


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        _ =
            Debug.log "Init with flags: " (toString flags)
    in
        ( { hueApiUrl = flags.hueApiUrl
          , ruterConfig = flags.ruterConfig
          , hasActiveLight = False
          , departures = []
          , now = timestampToDateTime flags.now
          }
        , Cmd.batch
            [ Task.perform GetTimeAndThenFetchDepartures Time.now
            , getLightStatus flags.hueApiUrl GetLightStatus
            ]
        )



---- UPDATE ----


timestampToDateTime : Time.Time -> DateTime
timestampToDateTime timestamp =
    Time.DateTime.fromTimestamp timestamp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TickLightStatus ->
            model ! [ getLightStatus model.hueApiUrl GetLightStatus ]

        TurnOffLightsClick ->
            model ! [ getLightStatus model.hueApiUrl GetLightStatusThenTurnOff ]

        TurnOffLightsResponse (Ok lightStatuses) ->
            let
                hasActiveLight =
                    isAnyLightActive lightStatuses
            in
                ( { model | hasActiveLight = hasActiveLight }, Cmd.none )

        TurnOffLightsResponse (Err err) ->
            let
                _ =
                    Debug.log "TurnOffLightsResponse Error" (toString err)
            in
                ( { model | hasActiveLight = True }, Cmd.none )

        GetLightStatus (Ok lightStatuses) ->
            let
                hasActiveLight =
                    isAnyLightActive lightStatuses
            in
                ({ model | hasActiveLight = hasActiveLight } ! [])

        GetLightStatus (Err err) ->
            let
                _ =
                    Debug.log "GetLightStatus Error" (toString err)
            in
                ( model, Cmd.none )

        GetLightStatusThenTurnOff (Ok lights) ->
            (model ! [ turnOffLightsInSequence model lights ])

        GetLightStatusThenTurnOff (Err err) ->
            let
                _ =
                    Debug.log "GetLightStatusThenTurnOff Error" (toString err)
            in
                ( model, Cmd.none )

        GetStopDepartures (Ok departures) ->
            let
                _ =
                    Debug.log "GetStopDepartures Ok" ""
            in
                ( { model | departures = departures }, Cmd.none )

        GetStopDepartures (Err err) ->
            let
                _ =
                    Debug.log "GetStopDepartures Error" (toString err)
            in
                ( model, Cmd.none )

        GetTimeAndThenFetchDepartures time ->
            let
                _ =
                    Debug.log "getime" (toString time)
            in
                ({ model | now = timestampToDateTime time } ! [ getStopDepartures 0 time ])

        RenderDeparturesAgain time ->
            ( { model | now = timestampToDateTime time }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ renderLightButton model.hasActiveLight
        , renderDepartures model.departures model.now
        ]


renderLightButton : Bool -> Html Msg
renderLightButton hasActiveLight =
    case hasActiveLight of
        True ->
            button [ onClick TurnOffLightsClick ] [ text "Skru av lysene" ]

        False ->
            button [ disabled True ] [ text "Alle lys er avslått" ]


isAfterNow : DateTime -> DateTime -> Bool
isAfterNow departureTime now =
    let
        timeOrder =
            Time.DateTime.compare departureTime now
    in
        case timeOrder of
            GT ->
                True

            _ ->
                False


renderDepartures : List Departure -> DateTime -> Html Msg
renderDepartures departures now =
    case departures of
        [] ->
            text ""

        _ ->
            div []
                (departures
                    |> List.filter (\d -> isAfterNow d.departure.expected now)
                    |> List.take 10
                    |> List.map (\d -> renderDeparture d now)
                )


printDepartureTime : DateTime -> DateTime -> String
printDepartureTime departureTime now =
    let
        deltaBetween =
            Time.DateTime.delta departureTime now

        minutesUntilDeparture =
            deltaBetween.minutes

        departureInLocalTime =
            Time.ZonedDateTime.fromDateTime (europe_oslo ()) departureTime

        timeToPrint =
            if minutesUntilDeparture == 0 then
                "nå"
            else if minutesUntilDeparture == 1 then
                "1 min"
            else if minutesUntilDeparture < 15 then
                (toString minutesUntilDeparture) ++ " " ++ "minutter"
            else
                (Time.ZonedDateTime.hour departureInLocalTime |> toString |> String.padLeft 2 '0')
                    ++ ":"
                    ++ (Time.ZonedDateTime.minute departureInLocalTime |> toString |> String.padLeft 2 '0')

        -- _ =
        --     Debug.log "between" (toString deltaBetween.minutes)
    in
        timeToPrint


renderDeparture : Departure -> DateTime -> Html Msg
renderDeparture departure now =
    div []
        [ p []
            [ span []
                [ text departure.lineNumber
                , text ": "
                , text departure.destination
                , text " – "
                , text (printDepartureTime departure.departure.expected now)
                ]
            ]
        ]



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (Time.second * 30) (always TickLightStatus)
        , Time.every (Time.second * 30) (always GetTimeAndThenFetchDepartures Time.now)
        , Time.every (Time.second * 1) (always RenderDeparturesAgain Time.now)
        ]


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
