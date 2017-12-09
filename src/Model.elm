module Model exposing (Model)

import Time.DateTime exposing (DateTime)
import Data.Flags exposing (RuterConfig)
import Data.Ruter exposing (Departure)


type alias Model =
    { hueApiUrl : String
    , ruterConfig : RuterConfig
    , hasActiveLight : Bool
    , departures : List Departure
    , now : DateTime
    }
