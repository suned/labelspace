module AppHomePage exposing (..)
import Html exposing (Html, text, h1)
import Html.Attributes exposing (type_, id)
import Html.Events exposing (onClick, on)
import Bulma
import Json.Decode as Decode
import Ports

type Msg
    = FileSelected

type alias Model =
    { token: String }

fileInputId = "fileInput"

setToken : String -> Model -> Model
setToken token model =
    { model | token = token }

view : Model -> Html Msg
view model = 
    Bulma.section
        [ h1 [ Bulma.titleClass ] [ text "Welcome to labelspace!" ]
        , Bulma.file [ Bulma.isLinkClass, id fileInputId, on "change" (Decode.succeed FileSelected) ] "upload"
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FileSelected -> (model, Ports.uploadToS3 (Ports.S3UploadData fileInputId model.token))