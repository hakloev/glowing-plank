module Messages exposing (Msg(..))

import Http
import Time exposing (Time)
import Data.Lights exposing (LightState)
import Data.Ruter exposing (Departure)


type Msg
    = TickLightStatus
    | TurnOffLightsClick
    | TurnOffLightsResponse (Result Http.Error (List LightState))
    | GetLightStatus (Result Http.Error (List LightState))
    | GetLightStatusThenTurnOff (Result Http.Error (List LightState))
    | GetStopDepartures (Result Http.Error (List Departure))
    | GetTimeAndThenFetchDepartures Time
    | RenderDeparturesAgain Time
