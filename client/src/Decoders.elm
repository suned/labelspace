module Decoders exposing (labelDecoder, userDecoder)

import Json.Decode
import Labels
import User


labelDecoder : Json.Decode.Decoder Labels.Label
labelDecoder =
    Json.Decode.map2
        Labels.Label
        (Json.Decode.field "ref" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "label" Json.Decode.string)


userDecoder : Json.Decode.Decoder User.User
userDecoder =
    Json.Decode.map2
        User.User
        (Json.Decode.field "email" Json.Decode.string)
        (Json.Decode.field "sub" (Json.Decode.nullable Json.Decode.string))
