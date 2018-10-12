module ConfirmUserPage exposing (..)
import Html.Styled exposing (Html, h1, text, p, a)
import Html.Styled.Attributes exposing (placeholder, autocomplete, value, href, disabled)
import Html.Styled.Events exposing (onInput, onClick)
import Bulma
import Ports
import Json.Encode as Encode
import Route

type Reason
    = CodeMismatch
    | Unknown

type State
    = Initial
    | Pending
    | Success
    | Error Reason

type alias Model =
    { confirmCode: String
    , username: String
    , state: State
    }

type Msg
  = SetConfirmCode String
  | Submit
  | ConfirmUserSuccess
  | ConfirmUserError Reason


setConfirmCode : String -> Model -> Model
setConfirmCode code model =
    { model | confirmCode = code }

setState : State -> Model -> Model
setState state model =
    { model | state = state }

setEmail : String -> Model -> Model
setEmail username model =
    { model | username = username }

encode : Model -> Encode.Value
encode model =
    Encode.object
        [ ("username", Encode.string model.username)
        , ("code", Encode.string model.confirmCode)
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetConfirmCode code ->
            let newModel = model |> setConfirmCode code
            in (newModel, Cmd.none)
        Submit -> (model |> setState Pending, Ports.confirmUser (encode model))
        ConfirmUserSuccess -> (model |> setState Success, Cmd.none)
        ConfirmUserError reason -> (model |> setState (Error reason), Cmd.none)

mapError : String -> Msg
mapError s =
    case s of
        "CodeMismatchException" -> ConfirmUserError CodeMismatch
        _ -> ConfirmUserError Unknown

buttonState model =
    case model.confirmCode of
        "" -> [ disabled True ]
        _ ->
            case model.state of
                Pending -> [ Bulma.isLoadingClass ]
                _ -> []

helpAttributes state =
    case state of
        Error _ -> [ Bulma.isDangerClass ]
        _ -> [ Bulma.isInvisibleClass ]

inputAttributes state =
    case state of
        Error CodeMismatch -> [ Bulma.isDangerClass ]
        _ -> []

helpMessage state =
    case state of
        Error CodeMismatch -> "The code you entered does not match"
        Error Unknown -> "An unknown error occurred. Try again later"
        _ -> "placeholder"

view : Model -> Html Msg
view model =
    case model.state of
        Success ->
            Bulma.section
                [h1 [ Bulma.titleClass ]
                    [ text "You've successfully registered!"]
                , p [ Bulma.subtitleClass ]
                    [ text "Procced to "
                    , a [href Route.loginRoute] [text "login"]
                    , text " to continue."
                    ]
                ]
        _ ->
            Bulma.section
                [h1 [ Bulma.titleClass ]
                    [ text "Confirm you email address"]
                , p [ Bulma.subtitleClass]
                    [text "Paste in the confirmation code sent to you by email"]
                , Bulma.labelledField "confirmation code"
                    [ Bulma.textInput
                        ([ placeholder "confirmation code"
                        , onInput SetConfirmCode
                        , value model.confirmCode
                        ] ++ inputAttributes model.state)
                    , Bulma.helpText (helpAttributes model.state) (helpMessage model.state)
                    ]
                , Bulma.field
                    [ Bulma.button
                        ([ Bulma.isLinkClass
                        , onClick Submit
                        , value model.username
                        ] ++ buttonState model)
                        "confirm"
                    ]
                ]
