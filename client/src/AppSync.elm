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


labelEncoder : Labels.Label -> Json.Encode.Value
labelEncoder label =
    Json.Encode.object
        [ ( "label", Json.Encode.string label.label )
        , ( "ref", maybeEncoder Json.Encode.string label.ref )
        ]


createLabelRequestEncoder : String -> Labels.Label -> Json.Encode.Value
createLabelRequestEncoder operation label =
    Json.Encode.object
        [ ( "operation", Json.Encode.string operation )
        , ( "data", labelEncoder label )
        ]


inviteTeamMemberRequestEncoder operation email =
    Json.Encode.object
        [ ( "operation", Json.Encode.string operation )
        , ( "data", Json.Encode.string email )
        ]


getDocumentRequestEncoder operation document =
    Json.Encode.object
        [ ( "operation", Json.Encode.string operation )
        , ( "data", Json.Encode.string document.ref )
        ]


requestEncoder : AppMsg.AppSyncRequest -> Json.Encode.Value
requestEncoder { operation, request } =
    case request of
        AppMsg.CreateDocumentLabelRequest label ->
            createLabelRequestEncoder operation label

        AppMsg.CreateSpanLabelRequest label ->
            createLabelRequestEncoder operation label

        AppMsg.CreateRelationLabelRequest label ->
            createLabelRequestEncoder operation label

        AppMsg.InviteTeamMemberRequest email ->
            inviteTeamMemberRequestEncoder operation email

        AppMsg.GetDocumentLinkRequest document ->
            getDocumentRequestEncoder operation document


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

        AppMsg.CreateSpanLabelRequest _ ->
            Porter.send porterConfig msg (Porter.simpleRequest { operation = "CreateSpanLabel", request = request })

        AppMsg.CreateRelationLabelRequest _ ->
            Porter.send porterConfig msg (Porter.simpleRequest { operation = "CreateRelationLabel", request = request })

        AppMsg.InviteTeamMemberRequest _ ->
            Porter.send porterConfig msg (Porter.simpleRequest { operation = "InviteTeamMember", request = request })

        AppMsg.GetDocumentLinkRequest _ ->
            Porter.send porterConfig msg (Porter.simpleRequest { operation = "GetDocumentLink", request = request })
