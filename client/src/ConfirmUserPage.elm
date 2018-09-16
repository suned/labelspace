module ConfirmUserPage exposing (..)
import Html exposing (Html, h1, text, p, a)
import Html.Attributes exposing (placeholder, autocomplete, value, href)
import Html.Events exposing (onInput, onClick)
import Bulma
import Ports
import Json.Encode as Encode
import Route


type State 
    = Initial
    | Success

type alias Model =
    { confirmCode: String
    , username: String
    , state: State
    }

type Msg
  = SetConfirmCode String
  | Submit
  | ConfirmUserSuccess ()


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
        Submit -> (model, Ports.confirmUser (encode model))
        ConfirmUserSuccess _ -> (model |> setState Success, Cmd.none)

view : Model -> Html Msg
view model =
    case model.state of
        Initial ->
            Bulma.section
                [h1 [ Bulma.titleClass ]
                    [ text "Confirm you email address"]
                , p [ Bulma.subtitleClass]
                    [text "Paste in the confirmation code sent to you by email"]
                , Bulma.labelledField "confirmation code"
                    (Bulma.textInput [ placeholder "confirmation code", onInput SetConfirmCode, value model.confirmCode])
                , Bulma.field (Bulma.button [ Bulma.isLinkClass, onClick Submit ] "submit" )
                ]
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
