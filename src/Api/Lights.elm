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



-- turnOffLightsInSequence : Model -> List LightState -> Cmd Msg
-- turnOffLightsInSequence model lights =
--     lights
--         |> List.map (\( lightId, state ) -> flipLightState model.hueApiUrl lightId False)
--         |> Task.sequence
--         |> Task.map List.concat
--         |> Task.attempt TurnOffLightsResponse
-- flipLightState : String -> String -> Bool -> Task.Task Http.Error (List LightState)
-- flipLightState hueApiUrl lightId state =
--     let
--         url =
--             hueApiUrl ++ "lights/" ++ lightId ++ "/state"
--         body =
--             Encode.object [ ( "on", Encode.bool state ) ]
--         decodeSuccess =
--             Decode.keyValuePairs Decode.bool
--         decoder =
--             Decode.index 0 (Decode.at [ "success" ] decodeSuccess)
--         request =
--             Http.request
--                 { method = "PUT"
--                 , headers = []
--                 , url = url
--                 , body = Http.jsonBody body
--                 , expect = Http.expectJson decoder
--                 , timeout = Nothing
--                 , withCredentials = False
--                 }
--     in
--         request |> Http.toTask
