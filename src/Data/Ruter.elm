module Data.Ruter exposing (..)

import Time.DateTime exposing (DateTime)


type alias DepartureTime =
    { aimed : DateTime
    , expected : DateTime
    }


type alias Departure =
    { lineColor : String
    , lineNumber : String
    , destination : String
    , departure : DepartureTime
    }
