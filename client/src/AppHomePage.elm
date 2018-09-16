module AppHomePage exposing (..)
import Html exposing (Html, text, h1)
import Html.Events exposing (onClick)
import Bulma

type Msg
    = ClickUploadButton

type alias Model =
    { token: String }

setToken : String -> Model -> Model
setToken token model =
    { model | token = token }

view : Model -> Html Msg
view model = 
    Bulma.section
        [ h1 [ Bulma.titleClass ] [ text "Welcome to labelspace!" ]
        , Bulma.field (Bulma.button [ Bulma.isLinkClass, onClick ClickUploadButton ] "upload")
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        _ -> (model, Cmd.none)