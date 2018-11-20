module AddLabelMenu exposing (AddLabelMenu, State(..), init, setLabel, setLabelType, setState, toggleIsOpen)

import AppMsg


type State
    = Init
    | Pending
    | Error


type alias AddLabelMenu =
    { isOpen : Bool
    , labelType : Maybe AppMsg.LabelType
    , label : String
    , state : State
    }


setLabelType : Maybe AppMsg.LabelType -> AddLabelMenu -> AddLabelMenu
setLabelType labelType model =
    { model | labelType = labelType }


toggleIsOpen : AddLabelMenu -> AddLabelMenu
toggleIsOpen model =
    { model | isOpen = not model.isOpen }


setState : State -> AddLabelMenu -> AddLabelMenu
setState state model =
    { model | state = state }


setLabel : String -> AddLabelMenu -> AddLabelMenu
setLabel label model =
    { model | label = label }


init =
    AddLabelMenu False Nothing "" Init
