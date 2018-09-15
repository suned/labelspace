module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Url
import Bulma
import Route
import RegisterPage
import ConfirmUserPage
import Ports




type alias Model =
  { key : Nav.Key
  , route: Route.Route
  , registerPageModel: RegisterPage.Model
  , confirmUserPageModel: ConfirmUserPage.Model
  }

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | ConfirmUserPageMsg ConfirmUserPage.Msg
  | RegisterPageMsg RegisterPage.Msg

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model
        key
        (Route.toRoute url)
        ( RegisterPage.Model key "" "" "" "" )
        ( ConfirmUserPage.Model "" "")
  , Cmd.none
  )



-- UPDATE
setRegisterModel : RegisterPage.Model -> Model -> Model
setRegisterModel registerModel model =
    { model | registerPageModel = registerModel }

setRoute : Route.Route -> Model -> Model
setRoute route model =
    { model | route = route }


setConfirmModel : ConfirmUserPage.Model -> Model -> Model
setConfirmModel confirmModel model =
    { model | confirmUserPageModel = confirmModel }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )
        Browser.External href ->
          ( model, Nav.load href )
    UrlChanged url -> 
        let newModel = model |> setRoute (Route.toRoute url)
        in case newModel.route of
            Route.Confirm username -> let confirmModel = ConfirmUserPage.Model "" username
                             in ( newModel |> setConfirmModel confirmModel
                                , Cmd.none
                                )
            Route.Home -> ( newModel, Cmd.none )
            Route.Pricing -> ( newModel, Cmd.none )
            Route.Register -> ( newModel, Cmd.none )
            Route.Login -> ( newModel, Cmd.none )
            Route.NotFound -> ( newModel, Cmd.none )
    RegisterPageMsg registerMsg ->
        let (registerModel, cmd) = RegisterPage.update registerMsg model.registerPageModel
        in (model |> setRegisterModel registerModel, Cmd.map (\m -> RegisterPageMsg m) cmd)
    ConfirmUserPageMsg confirmMsg ->
        let (confirmModel, cmd) = ConfirmUserPage.update confirmMsg model.confirmUserPageModel
        in (model |> setConfirmModel confirmModel, Cmd.map (\m -> ConfirmUserPageMsg m) cmd)




-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Sub.map (\m -> RegisterPageMsg m) (Ports.registerSuccess RegisterPage.RegisterSuccess)
        , Sub.map (\m -> ConfirmUserPageMsg m) (Ports.confirmUserSuccess ConfirmUserPage.ConfirmUserSuccess)
        ]



-- VIEW

navbarItem : String -> String -> Html Msg
navbarItem path label =
    a [class "navbar-item", href path ] [ text label ]

navbar : Html Msg
navbar =
    nav [ class "navbar is-primary" ]
        [ div [class "navbar-brand"]
            [ a [ class "navbar-item", href "/" ]
                [ img [ src "./assets/logo.png", alt "labelspace" ]
                    []
                ]
            ]
        , div [ class "navbar-menu" ]
            [ div [ class "navbar-start" ] []
            , div [ class "navbar-end" ]
                [ navbarItem Route.pricingRoute "pricing"
                , navbarItem Route.registerRoute "register"
                , navbarItem Route.loginRoute "login"
                ]
            ]
        ]


homeContent : Html Msg
homeContent =
    Bulma.section
        [ h1 [ Bulma.titleClass ]
            [ text "Easy Natural Language Annotation" ]
        , p [ Bulma.subtitleClass ] [ text "Some placeholder text explaining why this is a great product" ]
        ]


loginContent : Html Msg
loginContent =
    Bulma.section
        [ h1 [ Bulma.titleClass ] [ text "Login" ]
        , Bulma.labelledField "email" (Bulma.textInput [placeholder "email"])
        , Bulma.labelledField "password" (Bulma.passwordInput [])
        , Bulma.field (Bulma.button [ Bulma.isLinkClass ] "login")
        ]


content : Model -> Html Msg
content model =
    case model.route of
        Route.Home     -> homeContent
        Route.Register -> Html.map (\m -> RegisterPageMsg m) (RegisterPage.view model.registerPageModel)
        Route.Pricing  -> text "pricing"
        Route.Login    -> loginContent
        Route.NotFound -> text "Not Found"
        Route.Confirm username -> Html.map (\m -> ConfirmUserPageMsg m) (ConfirmUserPage.view model.confirmUserPageModel)


view : Model -> Browser.Document Msg
view model =
  { title = "labelspace"
  , body =
      [ navbar
      , content model
      ]
  }
