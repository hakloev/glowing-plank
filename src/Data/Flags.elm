module Data.Flags exposing (Flags, StopConfig)

import Time exposing (Time)


type alias StopConfig =
    { stopId : Int
    , timeToStop : Int
    , excludedLines : List String
    }


type alias Flags =
    { currentTime : Time
    , hueApiUrl : String
    , ruterStop : StopConfig
    }
