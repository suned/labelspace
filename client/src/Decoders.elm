module Decoders exposing (labelDecoder)

import AppModel
import Json.Decode


labelDecoder : Json.Decode.Decoder AppModel.Label
labelDecoder =
    Json.Decode.map2
        AppModel.Label
        (Json.Decode.field "ref" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "label" Json.Decode.string)
