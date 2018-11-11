module Model exposing (Model)

import AppModel
import Browser.Navigation as Nav
import ConfirmUserPage
import LoginPage
import RegisterPage
import Route


type alias Model =
    { key : Nav.Key
    , route : Route.Route
    , registerPageModel : RegisterPage.Model
    , confirmUserPageModel : ConfirmUserPage.Model
    , loginPageModel : LoginPage.Model
    , appHomePageModel : AppModel.Model
    }
