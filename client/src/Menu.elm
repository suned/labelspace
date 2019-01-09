module Menu exposing
    ( Menu
    , MenuMsg(..)
    , finishUpload
    , init
    , setUploadProgress
    , toggleDocumentLabelsMenu
    , toggleDocumentsMenu
    , toggleLabelsMenu
    , toggleRelationLabelsMenu
    , toggleSpanLabelsMenu
    , toggleTeamMenu
    )

import Dict
import Document
import Labels
import User


type MenuMsg
    = ToggleMenu
    | UploadProgress Float
    | OpenDocument Document.Document
    | ToggleAddLabelMenu
    | ToggleAddTeamMemberMenu
    | ToggleAddDocumentsMenu
    | ToggleDocumentsMenu
    | ToggleLabelsMenu
    | ToggleSpanLabelsMenu
    | ToggleRelationLabelsMenu
    | ToggleDocumentsLabelMenu
    | ToggleTeamMenu


type alias DocumentsMenu =
    { isOpen : Bool, uploadState : Maybe Float }


type alias TeamMenu =
    { isOpen : Bool }


type alias LabelsMenu =
    { isOpen : Bool, spanLabelsIsOpen : Bool, documentLabelsIsOpen : Bool, relationLabelsIsOpen : Bool }


type alias Menu =
    { isOpen : Bool
    , documents : DocumentsMenu
    , labels : LabelsMenu
    , team : TeamMenu
    }


finishUpload : Menu -> Menu
finishUpload menu =
    let
        oldDocumentsMenu =
            menu.documents

        newDocumentsMenu =
            { oldDocumentsMenu | uploadState = Nothing }
    in
    { menu | documents = newDocumentsMenu }


setUploadProgress : Float -> Menu -> Menu
setUploadProgress percent menu =
    let
        oldDocumentsMenu =
            menu.documents

        newDocumentsMenu =
            { oldDocumentsMenu | uploadState = Just percent }
    in
    { menu | documents = newDocumentsMenu }


toggleTeamMenu : Menu -> Menu
toggleTeamMenu menu =
    let
        oldTeamMenu =
            menu.team

        newTeam =
            { oldTeamMenu | isOpen = not oldTeamMenu.isOpen }
    in
    { menu | team = newTeam }


toggleDocumentLabelsMenu : Menu -> Menu
toggleDocumentLabelsMenu menu =
    let
        oldLabelsMenu =
            menu.labels

        newLabelsMenu =
            { oldLabelsMenu | documentLabelsIsOpen = not oldLabelsMenu.documentLabelsIsOpen }
    in
    { menu | labels = newLabelsMenu }


toggleDocumentsMenu : Menu -> Menu
toggleDocumentsMenu menu =
    let
        oldDocumentsMenu =
            menu.documents

        newDocumentsMenu =
            { oldDocumentsMenu | isOpen = not oldDocumentsMenu.isOpen }
    in
    { menu | documents = newDocumentsMenu }


toggleRelationLabelsMenu : Menu -> Menu
toggleRelationLabelsMenu menu =
    let
        oldLabelsMenu =
            menu.labels

        newLabelsMenu =
            { oldLabelsMenu | relationLabelsIsOpen = not oldLabelsMenu.relationLabelsIsOpen }
    in
    { menu | labels = newLabelsMenu }


toggleLabelsMenu : Menu -> Menu
toggleLabelsMenu menu =
    let
        oldLabelsMenu =
            menu.labels

        newLabelsMenu =
            { oldLabelsMenu | isOpen = not oldLabelsMenu.isOpen }
    in
    { menu | labels = newLabelsMenu }


toggleSpanLabelsMenu : Menu -> Menu
toggleSpanLabelsMenu menu =
    let
        oldLabelsMenu =
            menu.labels

        newLabelsMenu =
            { oldLabelsMenu | spanLabelsIsOpen = not oldLabelsMenu.spanLabelsIsOpen }
    in
    { menu | labels = newLabelsMenu }


init : Menu
init =
    { isOpen = True
    , documents = { isOpen = True, uploadState = Nothing }
    , labels = { isOpen = True, spanLabelsIsOpen = False, documentLabelsIsOpen = False, relationLabelsIsOpen = False }
    , team = { isOpen = True }
    }
