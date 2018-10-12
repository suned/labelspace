module LoginPage exposing (..)
import Html.Styled exposing (Html, text, h1, div, Attribute)
import Html.Styled.Attributes exposing (type_)
import Bulma
import Html.Styled.Attributes exposing (placeholder, disabled)
import Html.Styled.Events exposing (onInput, onClick)
import Ports
import Json.Encode as Encode
import Browser.Navigation as Nav
import Route
import Json.Decode as Decode

type Reason
    = IncorrectUserOrPassword
    | UserNotFound
    | Unknown

type State
    = Init
    | Pending
    | Error Reason

type alias Model =
    { username: String
    , password: String
    , token: Maybe String
    , key: Nav.Key
    , state: State
    }

type Msg
    = SetUsername String
    | SetPassword String
    | Submit
    | LoginSuccess String
    | LoginError Reason

decodeToken : Decode.Value -> Msg
decodeToken token =
    case Decode.decodeValue Decode.string token of
        Ok value -> LoginSuccess value
        Err _ -> Debug.todo "Could not parse token"

encode : Model -> Encode.Value
encode model =
    Encode.object
        [ ("username", Encode.string model.username)
        , ("password", Encode.string model.password)
        ]

setState : State -> Model -> Model
setState state model =
    {model | state = state }


mapError : String -> Msg
mapError s =
    case s of
        "UserNotFoundException" -> LoginError UserNotFound
        "NotAuthorizedException" -> LoginError IncorrectUserOrPassword
        _ -> LoginError Unknown

isEmpty : String -> Bool
isEmpty s =
    s == ""

anyFieldsEmpty : Model -> Bool
anyFieldsEmpty model =
    isEmpty model.username || isEmpty model.password

buttonAttributes : Model -> List (Attribute a)
buttonAttributes model =
    if anyFieldsEmpty model then [ disabled True ]
    else case model.state of
        Pending -> [Bulma.isLoadingClass]
        _ -> []


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetUsername username -> ({ model | username = username}, Cmd.none)
        SetPassword password -> ({model | password = password}, Cmd.none)
        Submit -> (model |> setState Pending, Ports.login (encode model))
        LoginSuccess token -> ({ model | token = Just token }, Nav.pushUrl model.key Route.appRoute)
        LoginError reason -> (model |> setState (Error reason), Cmd.none)

usernameAttributes : State -> List (Attribute a)
usernameAttributes state =
    case state of
        Error UserNotFound -> [ Bulma.isDangerClass ]
        _ -> []

usernameHelp : State -> List (Attribute a)
usernameHelp state =
    case state of
        Error UserNotFound -> [Bulma.isDangerClass]
        _ -> [Bulma.isInvisibleClass]

passwordHelp : State -> List (Attribute a)
passwordHelp state =
    case state of
        Error IncorrectUserOrPassword -> [Bulma.isDangerClass]
        Error Unknown -> [Bulma.isDangerClass]
        _ -> [Bulma.isInvisibleClass]

passwordHelpText : State -> String
passwordHelpText state =
    case state of
        Error IncorrectUserOrPassword -> "Incorrect username or password"
        Error Unknown -> "Unknown error occurred. Try again later"
        _ -> "placeholder"

view : Model -> Html Msg
view model =
    Bulma.section
        [ h1 [ Bulma.titleClass ] [ text "Login" ]
        , Bulma.labelledField
            "username"
            [ Bulma.textInput
                (
                [ placeholder "username"
                , onInput SetUsername
                ] ++ usernameAttributes model.state
                )
            , Bulma.helpText (usernameHelp model.state) "Unknown username"
            ]
        , Bulma.labelledField
            "password"
            [ Bulma.passwordInput [ onInput SetPassword]
            , Bulma.helpText (passwordHelp model.state) (passwordHelpText model.state)
            ]
        , Bulma.field
            [ Bulma.button
                ([ Bulma.isLinkClass, onClick Submit ] ++ buttonAttributes model)
                "login"
            ]
        ]
