module AddTeamMemberMenu exposing (Menu, State(..), init, setEmail, setState, toggle)


type State
    = Init
    | Pending
    | Success
    | Error


type alias Menu =
    { email : String
    , state : State
    , isOpen : Bool
    }


init =
    { email = ""
    , state = Init
    , isOpen = False
    }


toggle : Menu -> Menu
toggle model =
    { init | isOpen = not model.isOpen }


setState state model =
    { model | state = state }


setEmail : String -> Menu -> Menu
setEmail email model =
    { model | email = email }
