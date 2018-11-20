module AppModel exposing
    ( AddLabelMenu
    , AddLabelMenuMsg(..)
    , AddLabelMenuState(..)
    , AddMenuItem(..)
    , AppSyncMsg(..)
    , AppSyncRequest
    , DocumentLabel(..)
    , Label
    , LabelMenu
    , LabelType(..)
    , Menu
    , MenuItem(..)
    , MenuMsg(..)
    , Model
    , Msg(..)
    , RelationLabel(..)
    , Request(..)
    , SpanLabel(..)
    , addDocumentLabel
    , asAddLabelMenu
    , initAddLabelMenu
    , initModel
    , setAddLabelMenu
    , setApiUrl
    , setMenu
    , setToken
    )

import Http
import Json.Decode
import Porter


type AppSyncMsg
    = PorterMsg (Porter.Msg AppSyncRequest (Result String Json.Decode.Value) Msg)


type Msg
    = MenuMsg MenuMsg
    | AddLabelMenuMsg AddLabelMenuMsg
    | AppSyncMsg AppSyncMsg


type MenuMsg
    = ToggleMenu
    | ToggleMenuItem MenuItem
    | ToggleAddMenu AddMenuItem
    | OpenDocument


type AddLabelMenuMsg
    = ToggleAddLabelMenu
    | SetLabel String
    | Select LabelType
    | SaveLabel
    | CreateDocumentLabelResponse (Result String Json.Decode.Value)


type LabelType
    = Document
    | Span
    | Relation


type AddLabelMenuState
    = AddLabelMenuInit
    | AddLabelMenuPending
    | AddLabelMenuError


type alias AddLabelMenu =
    { isOpen : Bool
    , labelType : Maybe LabelType
    , label : String
    , state : AddLabelMenuState
    }


type AddMenuItem
    = AddDocumentsMenuItem
    | AddLabelMenuItem
    | AddTeamMemberMenuItem


type MenuItem
    = MenuItem
        { label : String
        , icon : String
        , isOpen : Bool
        , addItem : Maybe AddMenuItem
        , subItems : List MenuItem
        }


type alias LabelMenu =
    { isOpen : Bool
    , documentLabels : MenuItem
    , spanLabels : MenuItem
    , relationLables : MenuItem
    }


type alias Menu =
    { isOpen : Bool
    , documents : MenuItem
    , labels : LabelMenu
    , team : MenuItem
    }


type alias Label =
    { ref : Maybe String, label : String }


type DocumentLabel
    = DocumentLabel Label


type SpanLabel
    = SpanLabel Label


type RelationLabel
    = RelationLabel Label


type alias AddTeamMemberMenu =
    {}


type alias Editor =
    {}


type alias AppSyncRequest =
    { operation : String
    , request : Request
    }


type Request
    = CreateDocumentLabelRequest Label


type alias Model =
    { token : String
    , apiUrl : String
    , menu : Menu
    , addLabelMenu : AddLabelMenu
    , addTeamMemberMenu : AddTeamMemberMenu
    , documentLabels : List DocumentLabel
    , spanLabels : List SpanLabel
    , relationLabels : List RelationLabel
    , editor : Editor
    , porter : Porter.Model AppSyncRequest (Result String Json.Decode.Value) Msg
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


initAddLabelMenu =
    AddLabelMenu False Nothing "" AddLabelMenuInit


addDocumentLabelToMenu : DocumentLabel -> Menu -> Menu
addDocumentLabelToMenu (DocumentLabel { ref, label }) menu =
    let
        oldLabelsMenu =
            menu.labels

        (MenuItem oldDocumentLabels) =
            menu.labels.documentLabels

        subItems =
            labelMenuItem label :: oldDocumentLabels.subItems

        newDocumentLabels =
            MenuItem { oldDocumentLabels | subItems = subItems }

        newLabelsMenu =
            { oldLabelsMenu | documentLabels = newDocumentLabels }
    in
    { menu | labels = newLabelsMenu }


addDocumentLabel : DocumentLabel -> Model -> Model
addDocumentLabel label model =
    let
        newMenu =
            addDocumentLabelToMenu label model.menu

        oldLabels =
            model.documentLabels
    in
    { model | menu = newMenu, documentLabels = label :: oldLabels }


folderMenuItem : String -> MenuItem
folderMenuItem documentLabel =
    MenuItem { label = documentLabel, icon = "fas fa-folder", isOpen = False, subItems = [], addItem = Nothing }


teamMemberMenuItem : String -> MenuItem
teamMemberMenuItem teamMember =
    MenuItem { label = teamMember, icon = "fas fa-user", isOpen = False, subItems = [], addItem = Nothing }


labelMenuItem : String -> MenuItem
labelMenuItem label =
    MenuItem { label = label, icon = "fas fa-tag", isOpen = False, subItems = [], addItem = Nothing }


initModel : String -> String -> List DocumentLabel -> List SpanLabel -> List RelationLabel -> List String -> Model
initModel apiUrl token documentLabels spanLabels relationLabels team =
    { token = token
    , porter = Porter.init
    , apiUrl = apiUrl
    , editor = {}
    , documentLabels = documentLabels
    , relationLabels = relationLabels
    , spanLabels = spanLabels
    , addLabelMenu = initAddLabelMenu
    , addTeamMemberMenu = {}
    , menu =
        { isOpen = True
        , documents =
            MenuItem
                { label = "documents"
                , icon = "fas fa-copy"
                , isOpen = True
                , subItems =
                    List.map
                        (\(DocumentLabel { ref, label }) -> label)
                        documentLabels
                        |> List.map folderMenuItem
                , addItem = Just AddDocumentsMenuItem
                }
        , team =
            MenuItem
                { label = "team"
                , icon = "fas fa-users"
                , isOpen = True
                , addItem = Just AddTeamMemberMenuItem
                , subItems = List.map teamMemberMenuItem team
                }
        , labels =
            { isOpen = False
            , documentLabels =
                MenuItem
                    { label = "document labels"
                    , icon = "fas fa-file"
                    , isOpen = False
                    , addItem = Nothing
                    , subItems =
                        List.map
                            (\(DocumentLabel { ref, label }) -> label)
                            documentLabels
                            |> List.map labelMenuItem
                    }
            , spanLabels =
                MenuItem
                    { label = "span labels"
                    , icon = "fas fa-highlighter"
                    , isOpen = False
                    , addItem = Nothing
                    , subItems =
                        List.map
                            (\(SpanLabel { ref, label }) -> label)
                            spanLabels
                            |> List.map labelMenuItem
                    }
            , relationLables =
                MenuItem
                    { label = "relation labels"
                    , icon = "fas fa-link"
                    , isOpen = False
                    , addItem = Nothing
                    , subItems =
                        List.map
                            (\(RelationLabel { ref, label }) -> label)
                            relationLabels
                            |> List.map labelMenuItem
                    }
            }
        }
    }
