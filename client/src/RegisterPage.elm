module RegisterPage exposing (..)

import Html exposing (Html, h1, text, p)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onInput, onClick)
import Browser.Navigation as Nav
import Json.Encode as Encode
import Bulma
import Ports
import Route

type alias Model =
    { key: Nav.Key 
    , username: String
    , organization: String
    , email: String
    , password: String
    }

type Msg 
    = SetUsername String
    | SetEmail String
    | SetPassword String
    | SetOrganization String
    | Submit
    | RegisterSuccess ()



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
        Submit -> (model, Ports.register (encode model))
        RegisterSuccess _ -> ( model, Nav.pushUrl model.key (Route.confirmRoute model.username) )


view : Model -> Html Msg
view model =
    Bulma.section
        [ h1 [ Bulma.titleClass ]
            [ text "Sign up now!" ]
        , p [ Bulma.subtitleClass ]
            [ text "Fill in the fields below" ]
        , Bulma.labelledField "organization" (Bulma.textInput [placeholder "organization", onInput SetOrganization, value model.organization])
        , Bulma.labelledField "username" (Bulma.textInput [placeholder "username", onInput SetUsername, value model.username])
        , Bulma.labelledField "email" (Bulma.textInput [placeholder "email", onInput SetEmail, value model.email])
        , Bulma.labelledField "password" (Bulma.passwordInput [onInput SetPassword, value model.password])
        , Bulma.field (Bulma.button [ Bulma.isLinkClass, onClick Submit] "submit")
        ]
