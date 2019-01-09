module Decoders exposing (documentDecoder, documentLabelDecoder, labelDecoder, relationLabelDecoder, spanLabelDecoder, userDecoder)

import Document
import Json.Decode
import Labels
import User


labelDecoder : Json.Decode.Decoder Labels.Label
labelDecoder =
    Json.Decode.map2
        Labels.Label
        (Json.Decode.field "ref" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "label" Json.Decode.string)


spanLabelDecoder : Json.Decode.Decoder Labels.SpanLabel
spanLabelDecoder =
    Json.Decode.map Labels.SpanLabel labelDecoder


documentLabelDecoder : Json.Decode.Decoder Labels.DocumentLabel
documentLabelDecoder =
    Json.Decode.map Labels.DocumentLabel labelDecoder


relationLabelDecoder : Json.Decode.Decoder Labels.RelationLabel
relationLabelDecoder =
    Json.Decode.map Labels.RelationLabel labelDecoder


userDecoder : Json.Decode.Decoder User.User
userDecoder =
    Json.Decode.map2
        User.User
        (Json.Decode.field "email" Json.Decode.string)
        (Json.Decode.field "sub" (Json.Decode.nullable Json.Decode.string))


documentDecoder : Json.Decode.Decoder Document.Document
documentDecoder =
    Json.Decode.map2
        Document.Document
        (Json.Decode.field "ref" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
