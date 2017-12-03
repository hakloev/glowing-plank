module Main exposing (..)

import Html exposing (Html, text, div, img, button)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Time
import Json.Decode
import Json.Encode
import Http
import Task


---- MODEL ----


type alias Model =
    { hueApiUrl : String
    , lights : List LightState
    , hasActiveLight : Bool
    , error : String
    }


type Msg
    = TickLightStatus
    | TurnOffLightsClick
    | TurnOffLightsResponse (Result Http.Error (List LightState))
    | GetLightStatus LightStatusResponse
    | GetLightStatusThenTurnOff LightStatusResponse


type alias LightStatusResponse =
    Result Http.Error (List LightState)


type alias LightState =
    ( LightId, State )


type alias LightId =
    String


type alias State =
    Bool


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


turnOffLightRequest : Model -> String -> Task.Task Http.Error (List LightState)
turnOffLightRequest model lightId =
    let
        url =
            model.hueApiUrl ++ "lights/" ++ lightId ++ "/state"

        body =
            Json.Encode.object
                [ ( "on", Json.Encode.bool False )
                ]

        decodeSuccess =
            Json.Decode.keyValuePairs Json.Decode.bool

        decoder =
            Json.Decode.index 0 (Json.Decode.at [ "success" ] decodeSuccess)

        request =
            Http.request
                { method = "PUT"
                , headers = []
                , url = url
                , body = Http.jsonBody body
                , expect = Http.expectJson decoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        request |> Http.toTask


turnOffLightsInSequence : Model -> List LightState -> Cmd Msg
turnOffLightsInSequence model lights =
    lights
        |> List.map (\( lightId, state ) -> turnOffLightRequest model lightId)
        |> Task.sequence
        |> Task.map List.concat
        |> Task.attempt TurnOffLightsResponse


getLightStatus : Model -> (LightStatusResponse -> Msg) -> Cmd Msg
getLightStatus model msg =
    let
        url =
            model.hueApiUrl ++ "lights"

        request =
            Http.get url decodeLights
    in
        Http.send msg request


decodeLights : Json.Decode.Decoder (List LightState)
decodeLights =
    let
        decodeLight =
            Json.Decode.at [ "state", "on" ] Json.Decode.bool
    in
        Json.Decode.keyValuePairs decodeLight


isAnyLightActive : List LightState -> Bool
isAnyLightActive lights =
    let
        isActiveLight ( lightId, state ) =
            state
    in
        List.any isActiveLight lights


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
        [ Time.every (Time.second * 5) (always TickLightStatus)
        ]


main : Program Json.Decode.Value Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
