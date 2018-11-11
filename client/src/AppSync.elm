module AppSync exposing (AppSyncData, AppSyncMsg(..), sendToAppsync)

import AppModel
import Json.Decode
import Json.Encode
import Ports


type AppSyncMsg
    = CreateDocumentLabel AppModel.Label


type Msg
    = ReceiveDocumentLabel (Result String AppModel.Label)
    | UnknownAppSyncKey String


type alias AppSyncData =
    { operation : String
    , data : Json.Encode.Value
    }


maybeEncoder : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
maybeEncoder value maybe =
    case maybe of
        Just v ->
            value v

        Nothing ->
            Json.Encode.null


labelEncoder : AppModel.Label -> String -> Json.Encode.Value
labelEncoder label type_ =
    Json.Encode.object
        [ ( "label", Json.Encode.string label.label )
        , ( "labelType", Json.Encode.string type_ )
        , ( "ref", maybeEncoder Json.Encode.string label.ref )
        ]


sendToAppsync : AppSyncMsg -> Cmd msg
sendToAppsync appSyncMsg =
    case appSyncMsg of
        CreateDocumentLabel label ->
            { operation = "CreateDocumentLabel"
            , data = labelEncoder label "document"
            }
                |> toCmd


toCmd : AppSyncData -> Cmd msg
toCmd { operation, data } =
    [ ( "key", Json.Encode.string operation )
    , ( "data", data )
    ]
        |> Json.Encode.object
        |> Ports.toAppSync


dataDecoder : Json.Decode.Decoder a -> Json.Decode.Decoder a
dataDecoder =
    Json.Decode.field "data"


labelDecoder : Json.Decode.Decoder AppModel.Label
labelDecoder =
    Json.Decode.map2
        AppModel.Label
        (Json.Decode.nullable (Json.Decode.field "ref" Json.Decode.string))
        (Json.Decode.field "label" Json.Decode.string)


toAppSyncMsg : String -> Json.Decode.Decoder Msg
toAppSyncMsg key =
    case key of
        "CreateDocumentLabel" ->
            dataDecoder labelDecoder
                |> Json.Decode.map (Ok >> ReceiveDocumentLabel)

        _ ->
            Json.Decode.succeed (UnknownAppSyncKey key)
