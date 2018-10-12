module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Url
import Bulma
import Route
import RegisterPage
import ConfirmUserPage
import LoginPage
import Ports
import App
import Json.Decode as Decode
import Model exposing (Model)
import NavBar exposing (navbar)
import Menu


type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | ConfirmUserPageMsg ConfirmUserPage.Msg
  | RegisterPageMsg RegisterPage.Msg
  | LoginPageMsg LoginPage.Msg
  | AppHomePageMsg App.Msg

main : Program String Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }

init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init apiUrl url key =
    let route = Route.toRoute url
    in ( case route of
            Route.Confirm username ->
                Model
                    key
                    route
                    ( RegisterPage.Model key "" "" "" "" RegisterPage.Init)
                    ( ConfirmUserPage.Model "" username ConfirmUserPage.Initial)
                    ( LoginPage.Model "" "" Nothing key LoginPage.Init)
                    ( App.Model "" (Menu.initModel apiUrl "" [] [] [] []))
            _ ->
                Model
                    key
                    route
                    ( RegisterPage.Model key "" "" "" "" RegisterPage.Init )
                    ( ConfirmUserPage.Model "" "" ConfirmUserPage.Initial)
                    ( LoginPage.Model "" "" Nothing key LoginPage.Init)
                    ( App.Model "" (Menu.initModel apiUrl "" [] [] [] []))
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

setAppHomePageModel : App.Model -> Model -> Model
setAppHomePageModel appHomeModel model =
    { model | appHomePageModel = appHomeModel }


checkToken : Model -> (Model , Cmd Msg)
checkToken model =
    case model.loginPageModel.token of
        Just token ->
            let newAppModel = model.appHomePageModel |> App.setToken token
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
        let (appHomeModel, cmd) = App.update appHomeMsg model.appHomePageModel
        in (model |> setAppHomePageModel appHomeModel, Cmd.map (\m -> AppHomePageMsg m) cmd)



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Sub.map (\m -> RegisterPageMsg m) (Ports.registerSuccess (always RegisterPage.RegisterSuccess))
        , Sub.map (\m -> RegisterPageMsg m) (Ports.registerFailure RegisterPage.mapError)
        , Sub.map (\m -> ConfirmUserPageMsg m) (Ports.confirmUserSuccess (always ConfirmUserPage.ConfirmUserSuccess))
        , Sub.map (\m -> ConfirmUserPageMsg m) (Ports.confirmUserFailure ConfirmUserPage.mapError)
        , Sub.map (\m -> LoginPageMsg m) (Ports.loginSuccess LoginPage.decodeToken)
        , Sub.map (\m -> LoginPageMsg m) (Ports.loginFailure LoginPage.mapError)
        ]



-- VIEW
homeContent : Html.Html Msg
homeContent =
    Bulma.section
        [ Html.h1 [ Bulma.titleClass ]
            [ Html.text "Easy Natural Language Annotation" ]
        , Html.p [ Bulma.subtitleClass ] [ Html.text "Some placeholder text explaining why this is a great product" ]
        ]


content : Model -> Html.Html Msg
content model =
    case model.route of
        Route.Home     -> homeContent
        Route.Register -> Html.map (\m -> RegisterPageMsg m) (RegisterPage.view model.registerPageModel)
        Route.Pricing  -> Html.text "pricing"
        Route.Login    -> Html.map (\m -> LoginPageMsg m) (LoginPage.view model.loginPageModel)
        Route.NotFound -> Html.text "Not Found"
        Route.Confirm username -> Html.map (\m -> ConfirmUserPageMsg m) (ConfirmUserPage.view model.confirmUserPageModel)
        Route.App -> Html.map (\m -> AppHomePageMsg m) (App.view model.appHomePageModel)


view : Model -> Browser.Document Msg
view model =
  { title = "labelspace"
  , body =
      List.map
        Html.toUnstyled
        [ navbar model
        , content model
        ]
  }
