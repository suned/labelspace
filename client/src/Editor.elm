module Editor exposing (Editor, State(..), init, setState)


type State
    = Init
    | Ready String
    | Pending


type alias Editor =
    { state : State }


setState state editor =
    { editor | state = state }


init =
    { state = Init }
