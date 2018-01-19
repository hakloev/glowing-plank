module Api.Lights exposing (getLightState, setLightState)

import Http
import Task exposing (Task)
import Json.Encode as Encode
import Data.Lights exposing (LightState, decodeLightState)
import Messages exposing (Msg(SetLightStateReceived, LightStateReceived))


getLightState : String -> Cmd Msg
getLightState hueApiUrl =
    let
        url =
            hueApiUrl ++ "groups/0/"
    in
        Http.get url decodeLightState
            |> Http.toTask
            |> Task.attempt LightStateReceived


setLightState : String -> Bool -> Cmd Msg
setLightState hueApiUrl state =
    let
        url =
            hueApiUrl ++ "groups/0/action"

        body =
            Encode.object [ ( "on", Encode.bool state ) ]

        request =
            Http.request
                { method = "PUT"
                , headers = []
                , url = url
                , body = Http.jsonBody body
                , timeout = Nothing
                , withCredentials = False

                -- Ignore response
                , expect = Http.expectStringResponse (\_ -> Ok ())
                }
    in
        request
            |> Http.toTask
            |> Task.attempt SetLightStateReceived
