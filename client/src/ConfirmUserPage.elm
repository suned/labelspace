module ConfirmUserPage exposing (..)
import Html exposing (Html, h1, text, p)
import Html.Attributes exposing (placeholder, autocomplete, value)
import Html.Events exposing (onInput, onClick)
import Bulma
import Ports
import Json.Encode as Encode


type alias Model =
    { confirmCode: String
    , username: String
    }

type Msg
  = SetConfirmCode String
  | Submit
  | ConfirmUserSuccess ()


setConfirmCode : String -> Model -> Model
setConfirmCode code model =
    { model | confirmCode = code }

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
        ConfirmUserSuccess _ -> (model, Cmd.none)

view : Model -> Html Msg
view model =
    Bulma.section
        [h1 [ Bulma.titleClass ]
            [ text "Confirm you email address"]
        , p [ Bulma.subtitleClass]
            [text "Paste in the confirmation code sent to you by email"]
        , Bulma.labelledField "confirmation code"
            (Bulma.textInput [ placeholder "confirmation code", onInput SetConfirmCode, value model.confirmCode])
        , Bulma.field (Bulma.button [ Bulma.isLinkClass, onClick Submit ] "submit" )
        ]
