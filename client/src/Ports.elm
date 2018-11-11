port module Ports exposing (confirmUser, confirmUserFailure, confirmUserSuccess, login, loginFailure, loginSuccess, register, registerFailure, registerSuccess, toAppSync, upload)

import Json.Decode
import Json.Encode



-- Outgoing


port register : Json.Encode.Value -> Cmd msg


port confirmUser : Json.Encode.Value -> Cmd msg


port login : Json.Encode.Value -> Cmd msg


port upload : Json.Encode.Value -> Cmd msg


port toAppSync : Json.Encode.Value -> Cmd msg



-- Incoming


port registerSuccess : (() -> msg) -> Sub msg


port registerFailure : (( String, String ) -> msg) -> Sub msg


port confirmUserSuccess : (() -> msg) -> Sub msg


port confirmUserFailure : (String -> msg) -> Sub msg


port loginSuccess : (Json.Decode.Value -> msg) -> Sub msg


port loginFailure : (String -> msg) -> Sub msg
