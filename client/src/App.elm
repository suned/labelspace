module App exposing (fileInputId, setLoginData, setMenuModel, update, view)

import AddLabelMenu
import AddLabelMenuView
import AddTeamMemberMenuView
import AppModel
import AppMsg
import AppSync
import Bulma
import Css
import Editor
import EditorView
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import LoginData
import Menu
import MenuView
import Porter
import Ports


fileInputId : String
fileInputId =
    "fileInput"


setLoginData : LoginData.LoginData -> AppModel.Model -> AppModel.Model
setLoginData { token, team, spanLabels, documentLabels, relationLabels, documents } model =
    { model
        | token = token
        , teamMembers = team
        , spanLabels = spanLabels
        , documentLabels = documentLabels
        , relationLabels = relationLabels
        , documents = documents
    }


setMenuModel menuModel model =
    { model | menuModel = menuModel }


view : AppModel.Model -> Html.Html AppMsg.Msg
view model =
    Html.div [ Bulma.columnsClass ]
        [ MenuView.menu model
        , EditorView.editor model
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

        AppMsg.AddTeamMemberMenuMsg addTeamMemberMenuMsg ->
            AddTeamMemberMenuView.update addTeamMemberMenuMsg model

        AppMsg.EditorMsg editorMsg ->
            EditorView.update editorMsg model
