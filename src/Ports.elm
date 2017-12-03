port module Ports exposing (..)

import Json.Decode


port turnOffHueLights : Bool -> Cmd msg


port hueLightRequestDone : (Json.Decode.Value -> msg) -> Sub msg
