module Data.Flags exposing (..)

import Time
import Json.Decode as Decode


type alias RuterConfig =
    List RuterStop


type alias RuterStop =
    { stopId : Int
    , timeToStop : Int
    }


type alias Flags =
    { hueApiUrl : String
    , ruterConfig : RuterConfig
    , now : Time.Time
    }


ruterConfigDecoder : Decode.Decoder RuterConfig
ruterConfigDecoder =
    let
        stopsDecoder =
            Decode.map2 RuterStop
                (Decode.field "stopId" Decode.int)
                (Decode.field "timeToStop" Decode.int)
    in
        Decode.list stopsDecoder
