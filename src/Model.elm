module Model exposing (Model)

import Data.Flags exposing (RuterConfig)


type alias Model =
    { hueApiUrl : String
    , ruterConfig : RuterConfig
    , hasActiveLight : Bool
    }
