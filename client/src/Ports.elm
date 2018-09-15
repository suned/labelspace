port module Ports exposing (..)

import Json.Encode

-- Outgoing
port register : Json.Encode.Value -> Cmd msg
port confirmUser : Json.Encode.Value -> Cmd msg

-- Incoming
port registerSuccess : (() -> msg) -> Sub msg
port registerFailure : (String -> msg) -> Sub msg
port confirmUserSuccess : (() -> msg) -> Sub msg
port confirmUserFailure : (String -> msg) -> Sub msg