module LoginPage exposing (..)
import Html exposing (Html, text, h1)
import Html.Attributes exposing (type_)
import Bulma
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onInput, onClick)
import Ports
import Json.Encode as Encode
import Browser.Navigation as Nav
import Route
import Json.Decode as Decode

type alias Model =
    { username: String
    , password: String
    , token: Maybe String
    , key: Nav.Key
    }

type Msg
    = SetUsername String
    | SetPassword String
    | Submit
    | LoginSuccess String

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



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetUsername username -> ({ model | username = username}, Cmd.none)
        SetPassword password -> ({model | password = password}, Cmd.none)
        Submit -> (model, Ports.login (encode model))
        LoginSuccess token -> ({ model | token = Just token }, Nav.pushUrl model.key Route.appRoute)


view : Model -> Html Msg
view model =
    Bulma.section
        [ h1 [ Bulma.titleClass ] [ text "Login" ]
        , Bulma.labelledField "username" (Bulma.textInput [placeholder "username", onInput SetUsername])
        , Bulma.labelledField "password" (Bulma.passwordInput [onInput SetPassword])
        , Bulma.field (Bulma.button [ Bulma.isLinkClass, onClick Submit ] "login")
        ]