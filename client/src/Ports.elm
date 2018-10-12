port module Ports exposing (..)

import Json.Encode
import Json.Decode

-- Outgoing
port register : Json.Encode.Value -> Cmd msg
port confirmUser : Json.Encode.Value -> Cmd msg
port login : Json.Encode.Value -> Cmd msg
port upload : Json.Encode.Value -> Cmd msg

-- Incoming
port registerSuccess : (() -> msg) -> Sub msg
port registerFailure : ((String, String) -> msg) -> Sub msg
port confirmUserSuccess : (() -> msg) -> Sub msg
port confirmUserFailure : (String -> msg) -> Sub msg
port loginSuccess : (Json.Decode.Value -> msg) -> Sub msg
port loginFailure : (String -> msg) -> Sub msg
