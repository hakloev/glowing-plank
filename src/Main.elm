module Main exposing (..)

import Html exposing (Html, text, div, img, button)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Time
import Json.Decode as Decode
import Messages exposing (Msg(..))
import Model exposing (Model)
import Data.Flags exposing (ruterConfigDecoder)
import Data.Lights exposing (isAnyLightActive)
import Api.Lights exposing (getLightStatus, turnOffLightsInSequence)
import Api.Ruter exposing (getStopDepartures)


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        hueApiUrl =
            case Decode.decodeValue (Decode.field "HUE_API_URL" Decode.string) flags of
                Ok url ->
                    url

                Err err ->
                    Debug.log "hueApiUrl error" (toString err)

        ruterConfig =
            case Decode.decodeValue (Decode.at [ "RUTER", "stops" ] ruterConfigDecoder) flags of
                Ok config ->
                    config

                Err err ->
                    []
    in
        ( { hueApiUrl = hueApiUrl
          , ruterConfig = ruterConfig
          , hasActiveLight = False
          }
        , getStopDepartures 30
        )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TickLightStatus ->
            model ! [ getLightStatus model GetLightStatus ]

        TurnOffLightsClick ->
            model ! [ getLightStatus model GetLightStatusThenTurnOff ]

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
                    Debug.log "GetStopDepartures Ok" (toString departures)
            in
                ( model, Cmd.none )

        GetStopDepartures (Err err) ->
            let
                _ =
                    Debug.log "GetStopDepartures Error" (toString err)
            in
                ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ renderLightButton model.hasActiveLight
        ]


renderLightButton : Bool -> Html Msg
renderLightButton hasActiveLight =
    case hasActiveLight of
        True ->
            button [ onClick TurnOffLightsClick ] [ text "Skru av lysene" ]

        False ->
            button [ disabled True ] [ text "Alle lys er avslått" ]



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (Time.second * 30) (always TickLightStatus)
        ]


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
