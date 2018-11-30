module LoginPage exposing (LoginData, Model, Msg(..), Reason(..), State(..), anyFieldsEmpty, buttonAttributes, decodeLoginData, encode, isEmpty, mapError, passwordHelp, passwordHelpText, setState, update, usernameAttributes, usernameHelp, view)

import Browser.Navigation as Nav
import Bulma
import Html.Styled exposing (Attribute, Html, div, h1, text)
import Html.Styled.Attributes exposing (disabled, placeholder, type_)
import Html.Styled.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode
import Ports
import Route


type Reason
    = IncorrectUserOrPassword
    | UserNotFound
    | Unknown
    | DecodeError


type State
    = Init
    | Pending
    | Error Reason


type alias LoginData =
    { token : String
    , organization : String
    , organizationId : String
    }


type alias Model =
    { username : String
    , password : String
    , loginData : Maybe LoginData
    , key : Nav.Key
    , state : State
    }


type Msg
    = SetUsername String
    | SetPassword String
    | Submit
    | LoginSuccess LoginData
    | LoginError Reason


decodeLoginData : Decode.Value -> Msg
decodeLoginData data =
    let
        dataDecoder =
            Decode.map3 LoginData
                (Decode.field "token" Decode.string)
                (Decode.field "organization" Decode.string)
                (Decode.field "organizationId" Decode.string)
    in
    case Decode.decodeValue dataDecoder data of
        Ok loginData ->
            LoginSuccess loginData

        Err _ ->
            LoginError DecodeError


encode : Model -> Encode.Value
encode model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]


setState : State -> Model -> Model
setState state model =
    { model | state = state }


mapError : String -> Msg
mapError s =
    case s of
        "UserNotFoundException" ->
            LoginError UserNotFound

        "NotAuthorizedException" ->
            LoginError IncorrectUserOrPassword

        _ ->
            LoginError Unknown


isEmpty : String -> Bool
isEmpty s =
    s == ""


anyFieldsEmpty : Model -> Bool
anyFieldsEmpty model =
    isEmpty model.username || isEmpty model.password


buttonAttributes : Model -> List (Attribute a)
buttonAttributes model =
    if anyFieldsEmpty model then
        [ disabled True ]

    else
        case model.state of
            Pending ->
                [ Bulma.isLoadingClass ]

            _ ->
                []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            ( model |> setState Pending, Ports.login (encode model) )

        LoginSuccess loginData ->
            ( { model | loginData = Just loginData }, Nav.pushUrl model.key Route.appRoute )

        LoginError reason ->
            ( model |> setState (Error reason), Cmd.none )


usernameAttributes : State -> List (Attribute a)
usernameAttributes state =
    case state of
        Error UserNotFound ->
            [ Bulma.isDangerClass ]

        _ ->
            []


usernameHelp : State -> List (Attribute a)
usernameHelp state =
    case state of
        Error UserNotFound ->
            [ Bulma.isDangerClass ]

        _ ->
            [ Bulma.isInvisibleClass ]


passwordHelp : State -> List (Attribute a)
passwordHelp state =
    case state of
        Error IncorrectUserOrPassword ->
            [ Bulma.isDangerClass ]

        Error Unknown ->
            [ Bulma.isDangerClass ]

        _ ->
            [ Bulma.isInvisibleClass ]


passwordHelpText : State -> String
passwordHelpText state =
    case state of
        Error IncorrectUserOrPassword ->
            "Incorrect username or password"

        Error Unknown ->
            "Unknown error occurred. Try again later"

        _ ->
            "placeholder"


view : Model -> Html Msg
view model =
    Bulma.section
        [ h1 [ Bulma.titleClass ] [ text "Login" ]
        , Bulma.labelledField
            "username"
            [ Bulma.textInput
                ([ placeholder "username"
                 , onInput SetUsername
                 ]
                    ++ usernameAttributes model.state
                )
            , Bulma.helpText (usernameHelp model.state) "Unknown username"
            ]
        , Bulma.labelledField
            "password"
            [ Bulma.passwordInput [ onInput SetPassword ]
            , Bulma.helpText (passwordHelp model.state) (passwordHelpText model.state)
            ]
        , Bulma.field
            [ Bulma.button
                ([ Bulma.isLinkClass, onClick Submit ] ++ buttonAttributes model)
                "login"
            ]
        ]
