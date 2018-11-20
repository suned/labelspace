module App exposing (fileInputId, labelEditor, setMenuModel, setToken, update, view)

import AddLabelMenu
import AddLabelMenuView
import AppModel
import AppMsg
import AppSync
import Bulma
import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Menu
import MenuView
import Porter
import Ports


fileInputId : String
fileInputId =
    "fileInput"


setToken : String -> AppModel.Model -> AppModel.Model
setToken token model =
    { model | token = token }


setMenuModel menuModel model =
    { model | menuModel = menuModel }


labelEditor model =
    Html.div [ Bulma.columnClass ]
        [ Html.div [ Bulma.sectionClass ]
            [ Html.h1 [ Bulma.titleClass ] [ Html.text "Welcome to labelspace!" ] ]
        ]


view : AppModel.Model -> Html.Html AppMsg.Msg
view model =
    Html.div [ Bulma.columnsClass ]
        [ MenuView.menu model
        , labelEditor model
        ]


update : AppMsg.Msg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        AppMsg.MenuMsg menuMsg ->
            MenuView.update menuMsg model

        AppMsg.AddLabelMenuMsg addLabelMenuMsg ->
            AddLabelMenuView.update addLabelMenuMsg model

        AppMsg.AppSyncMsg (AppMsg.PorterMsg porterMsg) ->
            let
                ( porterModel, porterCmd ) =
                    Porter.update AppSync.porterConfig porterMsg model.porter
            in
            ( { model | porter = porterModel }, porterCmd )
