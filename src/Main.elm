module Main exposing (..)

import Html exposing (Html, text, div, img, button)
import Html.Events exposing (onClick)
import Ports exposing (turnOffHueLights)
import Time
import Json.Decode
import Http


---- MODEL ----


type alias Model =
    { hueApiUrl : String
    , lights : List ( String, LightState )
    , hasActiveLight : Bool
    , error : String
    }


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        hueApiUrl =
            case Json.Decode.decodeValue (Json.Decode.field "HUE_API_URL" Json.Decode.string) flags of
                Ok url ->
                    url

                Err _ ->
                    -- TOOD: Init model with error?
                    Debug.crash "HUE_API_URL decode error"
    in
        ( { hueApiUrl = hueApiUrl
          , lights = []
          , error = ""
          , hasActiveLight = False
          }
        , Cmd.none
        )



---- UPDATE ----


getLightStatus : Model -> Cmd Msg
getLightStatus model =
    let
        url =
            model.hueApiUrl ++ "lights"

        request =
            Http.get url decodeLights
    in
        Http.send GetLightStatus request


type alias LightState =
    { on : Bool
    }


decodeLights : Json.Decode.Decoder (List ( String, LightState ))
decodeLights =
    let
        decodeLight =
            Json.Decode.map LightState
                (Json.Decode.at [ "state", "on" ] Json.Decode.bool)
    in
        Json.Decode.keyValuePairs decodeLight


type Msg
    = NoOp
    | TurnOffHueLights
    | TestMsg
    | TickLightStatus
    | GetLightStatus (Result Http.Error (List ( String, LightState )))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TurnOffHueLights ->
            model ! [ turnOffHueLights True ]

        TestMsg ->
            ( model, Cmd.none )

        TickLightStatus ->
            model ! [ getLightStatus model ]

        GetLightStatus (Ok lights) ->
            let
                hasActiveLight =
                    List.any (\( lightId, state ) -> state.on) lights
            in
                ( { model
                    | lights = lights
                    , hasActiveLight = hasActiveLight
                  }
                , Cmd.none
                )

        GetLightStatus (Err err) ->
            ( { model | error = toString err }, Cmd.none )

        NoOp ->
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
            button [ onClick TurnOffHueLights ] [ text "Turn Off" ]

        False ->
            button [] [ text "Alle lys er avslått" ]



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.hueLightRequestDone (always TestMsg)
        , Time.every (Time.second * 5) (always TickLightStatus)
        ]


main : Program Json.Decode.Value Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
