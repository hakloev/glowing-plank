module Data.Ruter exposing (..)


type alias DepartureTime =
    { aimed : String
    , expected : String
    }


type alias Departure =
    { lineColor : String
    , lineNumber : String
    , destination : String
    , departure : DepartureTime
    }
