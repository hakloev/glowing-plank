module Api.Lights exposing (getLightState, setLightState)

import Http
import Json.Encode as Encode
import Data.Lights exposing (LightState, decodeLightState)
import Messages exposing (Msg(SetLightStateResponse, GetLightState))


getLightState : String -> Cmd Msg
getLightState hueApiUrl =
    let
        url =
            hueApiUrl ++ "groups/0/"

        request =
            Http.get url decodeLightState
    in
        Http.send GetLightState request


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
        Http.send SetLightStateResponse request
