module Messages exposing (Msg(..))

import Http
import Time exposing (Time)
import Data.Lights exposing (LightState)
import Data.Ruter exposing (Departure)


type Msg
    = TickLightStatus
    | TurnOffLightsClick
    | GetLightState (Result Http.Error LightState)
    | SetLightStateResponse (Result Http.Error ())
    | GetCurrentTimeAndThenFetchDepartures Time
    | GetStopDepartures (Result Http.Error (List Departure))
    | RenderDeparturesAgain Time
