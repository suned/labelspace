module Model exposing (..)
import Browser.Navigation as Nav
import Route
import RegisterPage
import ConfirmUserPage
import LoginPage
import App

type alias Model =
  { key : Nav.Key
  , route: Route.Route
  , registerPageModel: RegisterPage.Model
  , confirmUserPageModel: ConfirmUserPage.Model
  , loginPageModel: LoginPage.Model
  , appHomePageModel: App.Model
  }
