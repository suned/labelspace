module AddTeamMemberMenu exposing (Menu, State(..), init, setEmail, toggle)


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
    { model | isOpen = not model.isOpen }


setEmail : String -> Menu -> Menu
setEmail email model =
    { model | email = email }
