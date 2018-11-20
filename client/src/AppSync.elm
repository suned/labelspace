module AppSync exposing (porterConfig, send)

import AppMsg
import Json.Decode
import Json.Encode
import Labels
import Porter
import Ports


maybeEncoder : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
maybeEncoder value maybe =
    case maybe of
        Just v ->
            value v

        Nothing ->
            Json.Encode.null


labelEncoder : Labels.Label -> String -> Json.Encode.Value
labelEncoder label labelType =
    Json.Encode.object
        [ ( "label", Json.Encode.string label.label )
        , ( "labelType", Json.Encode.string labelType )
        , ( "ref", maybeEncoder Json.Encode.string label.ref )
        ]


requestEncoder : AppMsg.AppSyncRequest -> Json.Encode.Value
requestEncoder { operation, request } =
    case request of
        AppMsg.CreateDocumentLabelRequest label ->
            Json.Encode.object
                [ ( "operation", Json.Encode.string operation )
                , ( "data", labelEncoder label "document" )
                ]


handleError : Maybe String -> Json.Decode.Decoder (Result String Json.Decode.Value)
handleError result =
    case result of
        Just reason ->
            Json.Decode.succeed (Err reason)

        Nothing ->
            Json.Decode.map Ok (Json.Decode.field "data" Json.Decode.value)


responseDecoder : Json.Decode.Decoder (Result String Json.Decode.Value)
responseDecoder =
    Json.Decode.andThen handleError (Json.Decode.maybe (Json.Decode.field "error" Json.Decode.string))



-- TODO find a way to avoid passing Json.Decode.Value through to Caller Here


porterConfig : Porter.Config AppMsg.AppSyncRequest (Result String Json.Decode.Value) AppMsg.Msg
porterConfig =
    { outgoingPort = Ports.toAppSync
    , incomingPort = Ports.fromAppSync
    , encodeRequest = requestEncoder
    , decodeResponse = responseDecoder
    , porterMsg = AppMsg.AppSyncMsg << AppMsg.PorterMsg
    }


send : (Result String Json.Decode.Value -> AppMsg.Msg) -> AppMsg.Request -> Cmd AppMsg.Msg
send msg request =
    case request of
        AppMsg.CreateDocumentLabelRequest _ ->
            Porter.send porterConfig msg (Porter.simpleRequest { operation = "CreateDocumentLabel", request = request })
