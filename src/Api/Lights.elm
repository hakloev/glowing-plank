module Api.Lights exposing (..)

import Http
import Task
import Json.Decode as Decode
import Json.Encode as Encode
import Data.Lights exposing (LightState)
import Model exposing (Model)
import Messages exposing (Msg(TurnOffLightsResponse))


getLightStatus : String -> (Result Http.Error (List LightState) -> Msg) -> Cmd Msg
getLightStatus hueApiUrl msg =
    let
        url =
            hueApiUrl ++ "lights"

        request =
            Http.get url Data.Lights.decodeLights
    in
        Http.send msg request


flipLightState : Model -> String -> Bool -> Task.Task Http.Error (List LightState)
flipLightState model lightId state =
    let
        url =
            model.hueApiUrl ++ "lights/" ++ lightId ++ "/state"

        body =
            Encode.object
                [ ( "on", Encode.bool state )
                ]

        decodeSuccess =
            Decode.keyValuePairs Decode.bool

        decoder =
            Decode.index 0 (Decode.at [ "success" ] decodeSuccess)

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
        |> List.map (\( lightId, state ) -> flipLightState model lightId False)
        |> Task.sequence
        |> Task.map List.concat
        |> Task.attempt TurnOffLightsResponse
