module Data.Lights exposing (decodeLightState, LightState)

import Json.Decode as Decode


type alias LightState =
    { allOn : Bool
    , anyOn : Bool
    }


decodeLightState : Decode.Decoder LightState
decodeLightState =
    let
        decodeState =
            Decode.map2 LightState
                (Decode.field "all_on" Decode.bool)
                (Decode.field "any_on" Decode.bool)
    in
        Decode.at [ "state" ] decodeState
