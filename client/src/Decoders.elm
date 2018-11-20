module Decoders exposing (labelDecoder)

import Json.Decode
import Labels


labelDecoder : Json.Decode.Decoder Labels.Label
labelDecoder =
    Json.Decode.map2
        Labels.Label
        (Json.Decode.field "ref" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "label" Json.Decode.string)
