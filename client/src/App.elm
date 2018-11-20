module App exposing (fileInputId, labelEditor, setMenuModel, setToken, update, view)

import AddLabelMenu
import AppModel
import AppSync
import Bulma
import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Menu
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


view : AppModel.Model -> Html.Html AppModel.Msg
view model =
    Html.div [ Bulma.columnsClass ]
        [ Menu.menu model
        , labelEditor model
        ]


update : AppModel.Msg -> AppModel.Model -> ( AppModel.Model, Cmd AppModel.Msg )
update msg model =
    case msg of
        AppModel.MenuMsg menuMsg ->
            Menu.update menuMsg model

        AppModel.AddLabelMenuMsg addLabelMenuMsg ->
            AddLabelMenu.update addLabelMenuMsg model

        AppModel.AppSyncMsg (AppModel.PorterMsg porterMsg) ->
            let
                ( porterModel, porterCmd ) =
                    Porter.update AppSync.porterConfig porterMsg model.porter
            in
            ( { model | porter = porterModel }, porterCmd )
