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
import LoginPage
import Ports
import AppHomePage
import Json.Decode as Decode




type alias Model =
  { key : Nav.Key
  , route: Route.Route
  , registerPageModel: RegisterPage.Model
  , confirmUserPageModel: ConfirmUserPage.Model
  , loginPageModel: LoginPage.Model
  , appHomePageModel: AppHomePage.Model
  }

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | ConfirmUserPageMsg ConfirmUserPage.Msg
  | RegisterPageMsg RegisterPage.Msg
  | LoginPageMsg LoginPage.Msg
  | AppHomePageMsg AppHomePage.Msg

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
    let route = Route.toRoute url
    in ( Model
            key
            route
            ( RegisterPage.Model key "" "" "" "" )
            ( ConfirmUserPage.Model "" "" ConfirmUserPage.Initial)
            (LoginPage.Model "" "" Nothing key)
            (AppHomePage.Model "")
       , case route of
            Route.App -> Nav.pushUrl key Route.loginRoute
            _ -> Cmd.none
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

setLoginModel : LoginPage.Model -> Model -> Model
setLoginModel loginModel model =
    { model | loginPageModel = loginModel }

setAppHomePageModel : AppHomePage.Model -> Model -> Model
setAppHomePageModel appHomeModel model =
    { model | appHomePageModel = appHomeModel }


checkToken : Model -> (Model , Cmd Msg)
checkToken model =
    case model.loginPageModel.token of
        Just token -> 
            let newAppModel = model.appHomePageModel |> AppHomePage.setToken token
            in (model |> setAppHomePageModel newAppModel, Cmd.none)
        Nothing -> (model, Nav.pushUrl model.key Route.loginRoute)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
            case Route.toRoute url of
                Route.App -> checkToken model
                _ -> ( model, Nav.pushUrl model.key (Url.toString url) )
        Browser.External href ->
          ( model, Nav.load href )
    UrlChanged url -> 
        let newModel = model |> setRoute (Route.toRoute url)
        in case newModel.route of
            Route.Confirm username -> let confirmModel = ConfirmUserPage.Model "" username ConfirmUserPage.Initial
                             in ( newModel |> setConfirmModel confirmModel
                                , Cmd.none
                                )
            Route.App -> checkToken newModel
            _ -> ( newModel, Cmd.none )
    RegisterPageMsg registerMsg ->
        let (registerModel, cmd) = RegisterPage.update registerMsg model.registerPageModel
        in (model |> setRegisterModel registerModel, Cmd.map (\m -> RegisterPageMsg m) cmd)
    ConfirmUserPageMsg confirmMsg ->
        let (confirmModel, cmd) = ConfirmUserPage.update confirmMsg model.confirmUserPageModel
        in (model |> setConfirmModel confirmModel, Cmd.map (\m -> ConfirmUserPageMsg m) cmd)
    LoginPageMsg loginMsg ->
        let (loginModel, cmd) = LoginPage.update loginMsg model.loginPageModel
        in (model |> setLoginModel loginModel, Cmd.map (\m -> LoginPageMsg m) cmd)
    AppHomePageMsg appHomeMsg -> 
        let (appHomeModel, cmd) = AppHomePage.update appHomeMsg model.appHomePageModel
        in (model |> setAppHomePageModel appHomeModel, Cmd.map (\m -> AppHomePageMsg m) cmd)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Sub.map (\m -> RegisterPageMsg m) (Ports.registerSuccess RegisterPage.RegisterSuccess)
        , Sub.map (\m -> ConfirmUserPageMsg m) (Ports.confirmUserSuccess ConfirmUserPage.ConfirmUserSuccess)
        , Sub.map (\m -> LoginPageMsg m) (Ports.loginSuccess LoginPage.decodeToken)
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


content : Model -> Html Msg
content model =
    case model.route of
        Route.Home     -> homeContent
        Route.Register -> Html.map (\m -> RegisterPageMsg m) (RegisterPage.view model.registerPageModel)
        Route.Pricing  -> text "pricing"
        Route.Login    -> Html.map (\m -> LoginPageMsg m) (LoginPage.view model.loginPageModel)
        Route.NotFound -> text "Not Found"
        Route.Confirm username -> Html.map (\m -> ConfirmUserPageMsg m) (ConfirmUserPage.view model.confirmUserPageModel)
        Route.App -> Html.map (\m -> AppHomePageMsg m) (AppHomePage.view model.appHomePageModel)


view : Model -> Browser.Document Msg
view model =
  { title = "labelspace"
  , body =
      [ navbar
      , content model
      ]
  }
