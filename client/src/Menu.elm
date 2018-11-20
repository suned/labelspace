module Menu exposing (AddMenuItem(..), LabelMenu, Menu, MenuItem(..), addDocumentLabel, init)

import Labels


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


init : List Labels.DocumentLabel -> List Labels.SpanLabel -> List Labels.RelationLabel -> List String -> Menu
init documentLabels spanLabels relationLabels team =
    { isOpen = True
    , documents =
        MenuItem
            { label = "documents"
            , icon = "fas fa-copy"
            , isOpen = True
            , subItems =
                List.map
                    (\(Labels.DocumentLabel { ref, label }) -> label)
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
        { isOpen = True
        , documentLabels =
            MenuItem
                { label = "document labels"
                , icon = "fas fa-file"
                , isOpen = False
                , addItem = Nothing
                , subItems =
                    List.map
                        (\(Labels.DocumentLabel { ref, label }) -> label)
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
                        (\(Labels.SpanLabel { ref, label }) -> label)
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
                        (\(Labels.RelationLabel { ref, label }) -> label)
                        relationLabels
                        |> List.map labelMenuItem
                }
        }
    }


addDocumentLabel : Labels.DocumentLabel -> Menu -> Menu
addDocumentLabel (Labels.DocumentLabel { ref, label }) menu =
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


folderMenuItem : String -> MenuItem
folderMenuItem documentLabel =
    MenuItem { label = documentLabel, icon = "fas fa-folder", isOpen = False, subItems = [], addItem = Nothing }


teamMemberMenuItem : String -> MenuItem
teamMemberMenuItem teamMember =
    MenuItem { label = teamMember, icon = "fas fa-user", isOpen = False, subItems = [], addItem = Nothing }


labelMenuItem : String -> MenuItem
labelMenuItem label =
    MenuItem { label = label, icon = "fas fa-tag", isOpen = False, subItems = [], addItem = Nothing }
