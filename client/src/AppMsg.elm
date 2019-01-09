module AppMsg exposing (AddLabelMenuMsg(..), AddTeamMemberMenuMsg(..), AppSyncMsg(..), AppSyncRequest, EditorMsg(..), LabelType(..), Msg(..), Request(..))

import Document
import Json.Decode
import Labels
import Menu
import Porter


type LabelType
    = Document
    | Span
    | Relation


type alias AppSyncRequest =
    { operation : String
    , request : Request
    }


type Request
    = CreateDocumentLabelRequest Labels.Label
    | CreateSpanLabelRequest Labels.Label
    | CreateRelationLabelRequest Labels.Label
    | InviteTeamMemberRequest String
    | GetDocumentLinkRequest Document.Document


type AppSyncMsg
    = PorterMsg (Porter.Msg AppSyncRequest (Result String Json.Decode.Value) Msg)


type Msg
    = MenuMsg Menu.MenuMsg
    | AddLabelMenuMsg AddLabelMenuMsg
    | AppSyncMsg AppSyncMsg
    | AddTeamMemberMenuMsg AddTeamMemberMenuMsg
    | EditorMsg EditorMsg


type EditorMsg
    = GetDocumentLinkResponse (Result String Json.Decode.Value)


type AddLabelMenuMsg
    = ToggleAddLabelMenu
    | SetLabel String
    | Select LabelType
    | SaveLabel
    | CreateDocumentLabelResponse (Result String Json.Decode.Value)
    | CreateSpanLabelResponse (Result String Json.Decode.Value)
    | CreateRelationLabelResponse (Result String Json.Decode.Value)


type AddTeamMemberMenuMsg
    = ToggleAddTeamMemberMenu
    | SetEmail String
    | SaveTeamMember
    | InviteTeamMemberResponse (Result String Json.Decode.Value)
