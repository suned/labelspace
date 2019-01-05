module User exposing (User)


type alias User =
    { email : String
    , sub : Maybe String
    }
