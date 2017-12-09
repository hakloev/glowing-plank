module Model exposing (Model)

import Time.DateTime exposing (DateTime)
import Data.Flags exposing (RuterStop)
import Data.Ruter exposing (Departure)


type alias Model =
    { now : DateTime
    , hueApiUrl : String
    , ruterConfig : RuterStop
    , hasActiveLight : Bool
    , departures : List Departure
    }
