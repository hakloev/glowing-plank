module Data.Lights exposing (..)

import Json.Decode as Decode


type alias LightState =
    ( LightId, State )


type alias LightId =
    String


type alias State =
    Bool


decodeLights : Decode.Decoder (List LightState)
decodeLights =
    let
        decodeLight =
            Decode.at [ "state", "on" ] Decode.bool
    in
        Decode.keyValuePairs decodeLight


isAnyLightActive : List LightState -> Bool
isAnyLightActive lights =
    let
        isActiveLight ( lightId, state ) =
            state
    in
        List.any isActiveLight lights
