module AppModel exposing
    ( Model
    , addDocumentLabel
    , addRelationLabel
    , addSpanLabel
    , addTeamMember
    , asAddLabelMenu
    , asAddTeamMemberMenu
    , asEditor
    , asMenu
    , flip
    , initModel
    , setAddLabelMenu
    , setApiUrl
    , setEditor
    , setMenu
    , setToken
    )

import AddLabelMenu
import AddTeamMemberMenu
import AppMsg
import Document
import Editor
import Http
import Json.Decode
import Labels
import Menu
import Porter
import User


type alias Model =
    { token : String
    , organization : String
    , organizationId : String
    , apiUrl : String
    , menu : Menu.Menu
    , addLabelMenu : AddLabelMenu.AddLabelMenu
    , addTeamMemberMenu : AddTeamMemberMenu.Menu
    , documentLabels : List Labels.DocumentLabel
    , spanLabels : List Labels.SpanLabel
    , relationLabels : List Labels.RelationLabel
    , teamMembers : List User.User
    , documents : List Document.Document
    , openDocument : Maybe Document.Document
    , editor : Editor.Editor
    , porter : Porter.Model AppMsg.AppSyncRequest (Result String Json.Decode.Value) AppMsg.Msg
    }


setAddLabelMenu addLabelMenu model =
    { model | addLabelMenu = addLabelMenu }


setAddTeamMemberMenu addTeamMemberMenu model =
    { model | addTeamMemberMenu = addTeamMemberMenu }


asAddTeamMemberMenu =
    flip setAddTeamMemberMenu


flip : (a -> b -> c) -> (b -> a -> c)
flip f =
    \a b -> f b a


asAddLabelMenu =
    flip setAddLabelMenu


setMenu menu model =
    { model | menu = menu }


asMenu =
    flip setMenu


setToken token model =
    { model | token = token }


setApiUrl apiUrl model =
    { model | apiUrl = apiUrl }


addDocumentLabel : Labels.DocumentLabel -> Model -> Model
addDocumentLabel label model =
    let
        oldLabels =
            model.documentLabels
    in
    { model | documentLabels = label :: oldLabels }


addSpanLabel : Labels.SpanLabel -> Model -> Model
addSpanLabel label model =
    let
        oldLabels =
            model.spanLabels
    in
    { model | spanLabels = label :: oldLabels }


addRelationLabel : Labels.RelationLabel -> Model -> Model
addRelationLabel label model =
    let
        oldLabels =
            model.relationLabels
    in
    { model | relationLabels = label :: oldLabels }


addTeamMember user model =
    let
        oldTeam =
            model.teamMembers
    in
    { model | teamMembers = user :: oldTeam }


setEditor editor model =
    { model | editor = editor }


asEditor =
    flip setEditor


initModel : String -> String -> String -> String -> List Labels.DocumentLabel -> List Labels.SpanLabel -> List Labels.RelationLabel -> List User.User -> List Document.Document -> Model
initModel apiUrl token organizationId organization documentLabels spanLabels relationLabels team documents =
    { token = token
    , organization = organization
    , organizationId = organizationId
    , porter = Porter.init
    , apiUrl = apiUrl
    , openDocument = Nothing
    , editor = Editor.init
    , documentLabels = documentLabels
    , relationLabels = relationLabels
    , spanLabels = spanLabels
    , teamMembers = team
    , documents = documents
    , addLabelMenu = AddLabelMenu.init
    , addTeamMemberMenu = AddTeamMemberMenu.init
    , menu = Menu.init
    }
