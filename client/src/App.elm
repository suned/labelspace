module App exposing (..)
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Css
import Bulma
import Json.Decode as Decode
import Json.Encode as Encode
import Ports
import Menu

type alias Model =
    { token: String
    , menuModel: Menu.Model
    }

type Msg
  = MenuMsg Menu.Msg

fileInputId : String
fileInputId = "fileInput"

setToken : String -> Model -> Model
setToken token model =
  let newMenu = model.menuModel |> Menu.setToken token
  in { model | token = token, menuModel = newMenu }

setMenuModel menuModel model =
  { model | menuModel = menuModel }

labelEditor model =
  Html.div [Bulma.columnClass]
    [ Html.div [Bulma.sectionClass]
      [ Html.h1 [ Bulma.titleClass] [ Html.text "Welcome to labelspace!" ] ]
    ]
view : Model -> Html.Html Msg
view model =
  Html.div [Bulma.columnsClass]
    [ Html.map (\m -> MenuMsg m) (Menu.menu model.menuModel)
    , labelEditor model
    ]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        MenuMsg menuMsg ->
          let (newMenuModel, cmd) = Menu.update menuMsg model.menuModel
          in (model |> setMenuModel newMenuModel, Cmd.map (\c -> MenuMsg c) cmd)
