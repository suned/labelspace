module RegisterPage exposing (..)

import Html.Styled exposing (Html, h1, text, p, Attribute)
import Html.Styled.Attributes exposing (placeholder, value, disabled)
import Html.Styled.Events exposing (onInput, onClick)
import Browser.Navigation as Nav
import Json.Encode as Encode
import Bulma
import Ports
import Route

type Reason
    = UserExists
    | PasswordPolicyViolation
    | InvalidEmail
    | Unknown

type State
    = Init
    | Pending
    | Error Reason

type alias Model =
    { key: Nav.Key
    , username: String
    , organization: String
    , email: String
    , password: String
    , state: State
    }

type Msg
    = SetUsername String
    | SetEmail String
    | SetPassword String
    | SetOrganization String
    | Submit
    | RegisterSuccess
    | RegisterError Reason



setOrganization : String -> Model -> Model
setOrganization org model =
    { model | organization = org }

setPassword : String -> Model -> Model
setPassword password model =
    { model | password = password }

setEmail : String -> Model -> Model
setEmail email model =
    { model | email = email}

setUsername username model =
    { model | username = username }

setState state model =
    { model | state = state }

encode : Model -> Encode.Value
encode model =
    Encode.object
        [ ("email", Encode.string model.email)
        , ("username", Encode.string model.username)
        , ("organization", Encode.string model.organization)
        , ("password", Encode.string model.password)
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetOrganization org ->
            let newModel = model |> setOrganization org
            in (newModel, Cmd.none)
        SetEmail email ->
            let newModel = model |> setEmail email
            in (newModel, Cmd.none)
        SetUsername username ->
            let newModel = model |> setUsername username
            in (newModel, Cmd.none)
        SetPassword password ->
            let newModel = model |> setPassword password
            in (newModel, Cmd.none)
        Submit -> ( model |> setState Pending, Ports.register (encode model) )
        RegisterSuccess -> ( model |> setState Init, Nav.pushUrl model.key (Route.confirmRoute model.username) )
        RegisterError reason ->
            let newModel = model |> setState (Error reason)
            in ( newModel, Cmd.none )

mapError : (String, String) -> Msg
mapError (code, message) =
    case code of
        "UsernameExistsException" -> RegisterError UserExists
        "InvalidParameterException" ->
            case message of
            "Invalid email address format." -> RegisterError InvalidEmail
            _ -> RegisterError PasswordPolicyViolation
        _ -> RegisterError Unknown

isEmpty : String -> Bool
isEmpty s =
    s == ""

anyEmptyFields : Model -> Bool
anyEmptyFields model =
    isEmpty model.organization ||
    isEmpty model.username ||
    isEmpty model.email ||
    isEmpty model.password

buttonAttributes : Model -> List (Attribute Msg)
buttonAttributes model =
    if anyEmptyFields model then [ Bulma.isLinkClass, disabled True ]
    else case model.state of
        Pending -> [ Bulma.isLinkClass, Bulma.isLoadingClass ]
        _ -> [ Bulma.isLinkClass, onClick Submit]

usernameAttributes : State -> List (Attribute a)
usernameAttributes state =
    case state of
        Error UserExists -> [ Bulma.isDangerClass ]
        _ -> []

usernameHelp : State -> List (Attribute a)
usernameHelp state =
    case state of
        Error UserExists -> [ Bulma.isDangerClass ]
        _ -> [ Bulma.isInvisibleClass ]

passwordAttributes : State -> List (Attribute a)
passwordAttributes state =
    case state of
        Error PasswordPolicyViolation -> [ Bulma.isDangerClass ]
        _ -> []

passwordHelp : State -> List (Attribute a)
passwordHelp state =
    case state of
        Error PasswordPolicyViolation -> [ Bulma.isDangerClass ]
        _ -> [ Bulma.isInvisibleClass ]

passwordHelpText : State -> String
passwordHelpText state =
    case state of
        Error Unknown -> "Unknown error occurred. Try again later"
        Error PasswordPolicyViolation -> "Password must be longer than 6 characters"
        _ -> "placeholder"

emailHelp : State -> List (Attribute a)
emailHelp state =
    case state of
        Error InvalidEmail -> [Bulma.isDangerClass]
        _ -> [Bulma.isInvisibleClass]

view : Model -> Html Msg
view model =
    Bulma.section
        [ h1 [ Bulma.titleClass ]
            [ text "Sign up now!" ]
        , p [ Bulma.subtitleClass ]
            [ text "Fill in the fields below" ]
        , Bulma.field
            [ Bulma.labelledField
                "organization"
                [ Bulma.textInput
                    [ placeholder "organization"
                    , onInput SetOrganization
                    , value model.organization
                    ]
                ]
            , Bulma.labelledField
                "username"
                [ Bulma.textInput
                    (
                    [ placeholder "username"
                    , onInput SetUsername
                    , value model.username
                    ] ++ (usernameAttributes model.state)
                    )
                , Bulma.helpText (usernameHelp model.state) "Username is taken"
                ]
            , Bulma.labelledField
                "email"
                [ Bulma.textInput
                    [ placeholder "email"
                    , onInput SetEmail
                    , value model.email
                    ]
                , Bulma.helpText (emailHelp model.state) "Not a valid email address"
                ]
            , Bulma.labelledField
                "password"
                [ Bulma.passwordInput
                    (
                    [ onInput SetPassword
                    , value model.password
                    ] ++ (passwordAttributes model.state)
                    )
                , Bulma.helpText (passwordHelp model.state) (passwordHelpText model.state)
                ]
            , Bulma.field [ Bulma.button (buttonAttributes model) "sign up" ]
            ]
        ]
