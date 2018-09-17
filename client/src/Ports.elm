port module Ports exposing (..)

import Json.Encode
import Json.Decode

-- Outgoing
type alias S3UploadData =
    { id: String
    , token: String
    }
port register : Json.Encode.Value -> Cmd msg
port confirmUser : Json.Encode.Value -> Cmd msg
port login : Json.Encode.Value -> Cmd msg
port uploadToS3 : S3UploadData -> Cmd msg

-- Incoming
port registerSuccess : (() -> msg) -> Sub msg
port registerFailure : (String -> msg) -> Sub msg
port confirmUserSuccess : (() -> msg) -> Sub msg
port confirmUserFailure : (String -> msg) -> Sub msg
port loginSuccess : (Json.Decode.Value -> msg) -> Sub msg