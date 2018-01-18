module Data.Flags exposing (RuterStop, Flags)

import Time exposing (Time)


type alias RuterStop =
    { stopId : Int
    , timeToStop : Int
    , excludedLines : List String
    }


type alias Flags =
    { hueApiUrl : String
    , ruterConfig : RuterStop
    , currentTime : Time
    }
