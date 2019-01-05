module AppMsg exposing (AddLabelMenuMsg(..), AddTeamMemberMenuMsg(..), AppSyncMsg(..), AppSyncRequest, LabelType(..), MenuMsg(..), Msg(..), Request(..))

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


type AppSyncMsg
    = PorterMsg (Porter.Msg AppSyncRequest (Result String Json.Decode.Value) Msg)


type Msg
    = MenuMsg MenuMsg
    | AddLabelMenuMsg AddLabelMenuMsg
    | AppSyncMsg AppSyncMsg
    | AddTeamMemberMenuMsg AddTeamMemberMenuMsg


type MenuMsg
    = ToggleMenu
    | ToggleMenuItem Menu.MenuItem
    | ToggleAddMenu Menu.AddMenuItem
    | OpenDocument


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
