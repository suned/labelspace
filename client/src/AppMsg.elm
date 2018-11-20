module AppMsg exposing (AddLabelMenuMsg(..), AppSyncMsg(..), AppSyncRequest, LabelType(..), MenuMsg(..), Msg(..), Request(..))

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


type AppSyncMsg
    = PorterMsg (Porter.Msg AppSyncRequest (Result String Json.Decode.Value) Msg)


type Msg
    = MenuMsg MenuMsg
    | AddLabelMenuMsg AddLabelMenuMsg
    | AppSyncMsg AppSyncMsg


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
