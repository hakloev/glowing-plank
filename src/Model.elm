module Model
    exposing
        ( Model
        , initalModel
        )

import Data.Flags exposing (Flags)
import Data.Ruter exposing (Departure)


type alias Model =
    { config : Flags
    , hasActiveLight : Bool
    , departures : ( List Departure, List Departure )
    }


initalModel : Flags -> Model
initalModel flags =
    { config = flags
    , hasActiveLight = False
    , departures = ( [], [] )
    }
