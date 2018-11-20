module AppModel exposing
    ( Model
    , addDocumentLabel
    , asAddLabelMenu
    , initModel
    , setAddLabelMenu
    , setApiUrl
    , setMenu
    , setToken
    )

import AddLabelMenu
import AppMsg
import Http
import Json.Decode
import Labels
import Menu
import Porter


type alias AddTeamMemberMenu =
    {}


type alias Editor =
    {}


type alias Model =
    { token : String
    , apiUrl : String
    , menu : Menu.Menu
    , addLabelMenu : AddLabelMenu.AddLabelMenu
    , addTeamMemberMenu : AddTeamMemberMenu
    , documentLabels : List Labels.DocumentLabel
    , spanLabels : List Labels.SpanLabel
    , relationLabels : List Labels.RelationLabel
    , editor : Editor
    , porter : Porter.Model AppMsg.AppSyncRequest (Result String Json.Decode.Value) AppMsg.Msg
    }


setAddLabelMenu addLabelMenu model =
    { model | addLabelMenu = addLabelMenu }


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


initModel : String -> String -> List Labels.DocumentLabel -> List Labels.SpanLabel -> List Labels.RelationLabel -> List String -> Model
initModel apiUrl token documentLabels spanLabels relationLabels team =
    { token = token
    , porter = Porter.init
    , apiUrl = apiUrl
    , editor = {}
    , documentLabels = documentLabels
    , relationLabels = relationLabels
    , spanLabels = spanLabels
    , addLabelMenu = AddLabelMenu.init
    , addTeamMemberMenu = {}
    , menu = Menu.init documentLabels spanLabels relationLabels team
    }
