module AppMsg exposing (AddLabelMenuMsg(..), MenuMsg(..), Msg(..))

import ApiClient
import AppModel
import Http


type Msg
    = MenuMsg MenuMsg
    | AddLabelMenuMsg AddLabelMenuMsg


type MenuMsg
    = ToggleMenu
    | ToggleMenuItem AppModel.MenuItem
    | ToggleAddMenu AppModel.AddMenuItem
    | OpenDocument


type AddLabelMenuMsg
    = ToggleAddLabelMenu
    | SetLabel String
    | Select AppModel.LabelType
    | SaveLabel
    | Response (Result Http.Error ApiClient.Label)
