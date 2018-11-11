module AppModel exposing
    ( AddLabelMenu
    , AddLabelMenuState(..)
    , AddMenuItem(..)
    , DocumentLabel(..)
    , Label
    , LabelType(..)
    , Menu
    , MenuItem(..)
    , Model
    , RelationLabel(..)
    , SpanLabel(..)
    , addLabel
    , asAddLabelMenu
    , initAddLabelMenu
    , initModel
    , setAddLabelMenu
    , setApiUrl
    , setMenu
    , setToken
    )

import ApiClient


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


type alias Menu =
    { isOpen : Bool
    , documents : MenuItem
    , labels : MenuItem
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


folderMenuItem : String -> MenuItem
folderMenuItem documentLabel =
    MenuItem { label = documentLabel, icon = "fas fa-folder", isOpen = False, subItems = [], addItem = Nothing }


teamMemberMenuItem : String -> MenuItem
teamMemberMenuItem teamMember =
    MenuItem { label = teamMember, icon = "fas fa-user", isOpen = False, subItems = [], addItem = Nothing }


labelMenuItem : String -> MenuItem
labelMenuItem label =
    MenuItem { label = label, icon = "fas fa-tag", isOpen = False, subItems = [], addItem = Nothing }


addLabel : ApiClient.Label -> Model -> Model
addLabel apiLabel model =
    case apiLabel of
        ApiClient.DocumentLabel { ref, label } ->
            { model | documentLabels = model.documentLabels ++ [ DocumentLabel { ref = ref, label = label } ] }

        ApiClient.SpanLabel { ref, label } ->
            { model | documentLabels = model.documentLabels ++ [ DocumentLabel { ref = ref, label = label } ] }

        ApiClient.RelationLabel { ref, label } ->
            { model | documentLabels = model.documentLabels ++ [ DocumentLabel { ref = ref, label = label } ] }


initModel : String -> String -> List DocumentLabel -> List SpanLabel -> List RelationLabel -> List String -> Model
initModel apiUrl token documentLabels spanLabels relationLabels team =
    { token = token
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
        , labels =
            MenuItem
                { label = "labels"
                , icon = "fas fa-tags"
                , isOpen = True
                , addItem = Just AddLabelMenuItem
                , subItems =
                    [ MenuItem
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
                    , MenuItem
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
                    , MenuItem
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
                    ]
                }
        , team =
            MenuItem
                { label = "team"
                , icon = "fas fa-users"
                , isOpen = True
                , addItem = Just AddTeamMemberMenuItem
                , subItems = List.map teamMemberMenuItem team
                }
        }
    }
