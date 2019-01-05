module AppModel exposing
    ( Model
    , addDocumentLabel
    , addRelationLabel
    , addSpanLabel
    , addTeamMember
    , asAddLabelMenu
    , asAddTeamMemberMenu
    , initModel
    , setAddLabelMenu
    , setApiUrl
    , setMenu
    , setToken
    )

import AddLabelMenu
import AddTeamMemberMenu
import AppMsg
import Http
import Json.Decode
import Labels
import Menu
import Porter
import User


type alias Editor =
    {}


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
    , editor : Editor
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


setToken token model =
    { model | token = token }


setApiUrl apiUrl model =
    { model | apiUrl = apiUrl }


addDocumentLabel : Labels.DocumentLabel -> Model -> Model
addDocumentLabel label model =
    let
        newMenu =
            Menu.addDocumentLabel label model.menu

        oldLabels =
            model.documentLabels
    in
    { model | menu = newMenu, documentLabels = label :: oldLabels }


addSpanLabel : Labels.SpanLabel -> Model -> Model
addSpanLabel label model =
    let
        newMenu =
            Menu.addSpanLabel label model.menu

        oldLabels =
            model.spanLabels
    in
    { model | menu = newMenu, spanLabels = label :: oldLabels }


addRelationLabel : Labels.RelationLabel -> Model -> Model
addRelationLabel label model =
    let
        newMenu =
            Menu.addRelationLabel label model.menu

        oldLabels =
            model.relationLabels
    in
    { model | menu = newMenu, relationLabels = label :: oldLabels }


addTeamMember user model =
    let
        newMenu =
            Menu.addTeamMember user model.menu

        oldTeam =
            model.teamMembers
    in
    { model | menu = newMenu, teamMembers = user :: oldTeam }


initModel : String -> String -> String -> String -> List Labels.DocumentLabel -> List Labels.SpanLabel -> List Labels.RelationLabel -> List User.User -> Model
initModel apiUrl token organizationId organization documentLabels spanLabels relationLabels team =
    { token = token
    , organization = organization
    , organizationId = organizationId
    , porter = Porter.init
    , apiUrl = apiUrl
    , editor = {}
    , documentLabels = documentLabels
    , relationLabels = relationLabels
    , spanLabels = spanLabels
    , teamMembers = []
    , addLabelMenu = AddLabelMenu.init
    , addTeamMemberMenu = AddTeamMemberMenu.init
    , menu = Menu.init documentLabels spanLabels relationLabels (List.map (\m -> m.email) team)
    }
