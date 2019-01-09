module LoginPage exposing (LoginData, Model, Msg(..), Reason(..), State(..), anyFieldsEmpty, buttonAttributes, decodeLoginData, encode, isEmpty, mapError, passwordHelp, passwordHelpText, setState, update, usernameAttributes, usernameHelp, view)

import AttributeBuilder
import Browser.Navigation as Nav
import Bulma
import Decoders
import Document
import Html.Styled exposing (Attribute, Html, div, h1, text)
import Html.Styled.Attributes exposing (disabled, placeholder, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode
import Labels
import Ports
import Route
import User


type Reason
    = IncorrectUserOrPassword
    | UserNotFound
    | Unknown
    | DecodeError


type State
    = Init
    | Pending
    | Error Reason
    | NewPasswordRequiredState
    | NewPasswordPending
    | NewPasswordErrorState


type alias LoginData =
    { token : String
    , team : List User.User
    , documents : List Document.Document
    , spanLabels : List Labels.SpanLabel
    , documentLabels : List Labels.DocumentLabel
    , relationLabels : List Labels.RelationLabel
    }


type alias Model =
    { username : String
    , password : String
    , newPassword : String
    , loginData : Maybe LoginData
    , key : Nav.Key
    , state : State
    }


type Msg
    = SetUsername String
    | SetPassword String
    | SetNewPassword String
    | Submit
    | LoginSuccess LoginData
    | LoginError Reason
    | NewPasswordRequired
    | NewPasswordChallenge
    | NewPasswordError


decodeLoginData : Decode.Value -> Msg
decodeLoginData data =
    let
        dataDecoder =
            Decode.map6 LoginData
                (Decode.field "token" Decode.string)
                (Decode.field "team" (Decode.list Decoders.userDecoder))
                (Decode.field "documents" (Decode.list Decoders.documentDecoder))
                (Decode.field "spanLabels" (Decode.list Decoders.spanLabelDecoder))
                (Decode.field "documentLabels" (Decode.list Decoders.documentLabelDecoder))
                (Decode.field "relationLabels" (Decode.list Decoders.relationLabelDecoder))
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
        , ( "newPassword", Encode.string model.newPassword )
        ]


setState : State -> Model -> Model
setState state model =
    { model | state = state }


setPassword : String -> Model -> Model
setPassword password model =
    { model | password = password }


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
            ( model |> setPassword password, Cmd.none )

        SetNewPassword password ->
            ( { model | newPassword = password }, Cmd.none )

        Submit ->
            ( model |> setState Pending, Ports.login (encode model) )

        LoginSuccess loginData ->
            ( { model | loginData = Just loginData }, Nav.pushUrl model.key Route.appRoute )

        LoginError reason ->
            ( model |> setState (Error reason), Cmd.none )

        NewPasswordRequired ->
            ( model |> setState NewPasswordRequiredState, Cmd.none )

        NewPasswordChallenge ->
            ( model |> setState NewPasswordPending, Ports.newPasswordChallenge (encode model) )

        NewPasswordError ->
            ( model |> setState NewPasswordErrorState, Cmd.none )


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


newPasswordView model =
    Bulma.section
        [ h1 [ Bulma.titleClass ] [ text "New Password Required" ]
        , Bulma.labelledField
            "password"
            [ Bulma.passwordInput [ onInput SetNewPassword, value model.newPassword ]
            , Bulma.helpText (passwordHelp model.state) (passwordHelpText model.state)
            ]
        , Bulma.field
            [ Bulma.button
                ([ Bulma.isLinkClass, onClick NewPasswordChallenge ]
                    |> AttributeBuilder.addIf (model.state == NewPasswordPending) [ Bulma.isLoadingClass ]
                    |> AttributeBuilder.addIf (model.newPassword == "") [ disabled True ]
                )
                "login"
            ]
        ]


view : Model -> Html Msg
view model =
    case model.state of
        NewPasswordRequiredState ->
            newPasswordView model

        NewPasswordPending ->
            newPasswordView model

        NewPasswordErrorState ->
            newPasswordView model

        _ ->
            Bulma.section
                [ h1 [ Bulma.titleClass ] [ text "Login" ]
                , Bulma.labelledField
                    "email"
                    [ Bulma.textInput
                        ([ placeholder "email"
                         , onInput SetUsername
                         ]
                            ++ usernameAttributes model.state
                        )
                    , Bulma.helpText (usernameHelp model.state) "Unknown user"
                    ]
                , Bulma.labelledField
                    "password"
                    [ Bulma.passwordInput [ onInput SetPassword, value model.password ]
                    , Bulma.helpText (passwordHelp model.state) (passwordHelpText model.state)
                    ]
                , Bulma.field
                    [ Bulma.button
                        ([ Bulma.isLinkClass, onClick Submit ] ++ buttonAttributes model)
                        "login"
                    ]
                ]
