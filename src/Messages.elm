module Messages exposing (Msg(..))

import Http
import Time exposing (Time)
import Data.Lights exposing (LightState)
import Data.Ruter exposing (Departure)


type Msg
    = NoOp
      -- Hue API and user actions
    | TickLightStatus
    | TurnOffLightsClick
    | LightStateReceived (Result Http.Error LightState)
    | SetLightStateReceived (Result Http.Error ())
      -- Ruter API and actions
    | TickDepartureFetch
    | TickDepartureReRender Time
    | DeparturesReceived (Result Http.Error (List Departure))
