module Main exposing (main)

import Html exposing (Html, text, div, img, button, p, span, ul, li)
import Html.Attributes exposing (disabled, class, id, style)
import Html.Events exposing (onClick)
import Time exposing (Time)
import Messages exposing (Msg(..))
import Model exposing (Model, initalModel)
import Data.Flags exposing (Flags)
import Data.Ruter exposing (Departure, getRelevantDepartures)
import Api.Lights exposing (getLightState, setLightState)
import Api.Ruter exposing (getStopDepartures)
import View.Ruter


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        _ =
            Debug.log "Init app with flags" (toString flags)
    in
        ( initalModel flags
        , Cmd.batch
            [ getStopDepartures flags.ruterStop
            , getLightState flags.hueApiUrl
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ config } as model) =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        TickLightStatus ->
            model ! [ getLightState config.hueApiUrl ]

        TurnOffLightsClick ->
            model ! [ setLightState config.hueApiUrl False ]

        LightStateReceived (Ok lightState) ->
            ({ model | hasActiveLight = lightState.anyOn } ! [])

        LightStateReceived (Err err) ->
            let
                _ =
                    Debug.log "LightStateReceived error" (toString err)
            in
                ( model, Cmd.none )

        SetLightStateReceived (Ok _) ->
            ( model, getLightState config.hueApiUrl )

        SetLightStateReceived (Err err) ->
            let
                _ =
                    Debug.log "SetLightStateReceived error" (toString err)
            in
                ( model, Cmd.none )

        TickDepartureFetch ->
            model ! [ getStopDepartures config.ruterStop ]

        DeparturesReceived (Ok departures) ->
            ( { model
                | departures = getRelevantDepartures departures config.ruterStop.excludedLines
              }
            , Cmd.none
            )

        DeparturesReceived (Err err) ->
            let
                _ =
                    Debug.log "DeparturesReceived error" (toString err)
            in
                ( model, Cmd.none )

        TickDepartureReRender time ->
            let
                updatedConfig =
                    { config | currentTime = time }
            in
                ( { model | config = updatedConfig }, Cmd.none )


view : Model -> Html Msg
view ({ config } as model) =
    div [ id "container" ]
        [ View.Ruter.view model.departures config.currentTime

        -- , renderButtons model.hasActiveLight
        ]


renderButtons : Bool -> Html Msg
renderButtons hasActiveLight =
    div [ id "buttons" ]
        [ renderLightButton hasActiveLight
        , renderSonosButton
        ]


renderSonosButton : Html Msg
renderSonosButton =
    button [ class "button" ] [ text "Skru av SONOS" ]


renderLightButton : Bool -> Html Msg
renderLightButton hasActiveLight =
    case hasActiveLight of
        True ->
            button [ class "button", onClick TurnOffLightsClick ] [ text "Skru av lysene" ]

        False ->
            button [ class "button", disabled True ] [ text "Alle lys er avslått" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (Time.second * 30) (always TickLightStatus)
        , Time.every (Time.second * 30) (always TickDepartureFetch)
        , Time.every (Time.second * 1) (always TickDepartureReRender Time.now)
        ]


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
