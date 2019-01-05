module Menu exposing (AddMenuItem(..), Menu, MenuItem(..), addDocumentLabel, addRelationLabel, addSpanLabel, addTeamMember, init)

import Dict
import Labels
import User


type AddMenuItem
    = AddDocumentsMenuItem
    | AddLabelMenuItem
    | AddTeamMemberMenuItem


type MenuItem
    = MenuItem
        { icon : String
        , isOpen : Bool
        , addItem : Maybe AddMenuItem
        , subItems : Dict.Dict String MenuItem
        }


type alias Menu =
    { isOpen : Bool
    , documents : Dict.Dict String MenuItem
    , labels : Dict.Dict String MenuItem
    , team : Dict.Dict String MenuItem
    }


init : List Labels.DocumentLabel -> List Labels.SpanLabel -> List Labels.RelationLabel -> List String -> Menu
init documentLabels spanLabels relationLabels team =
    { isOpen = True
    , documents =
        Dict.fromList
            [ ( "documents"
              , MenuItem
                    { icon = "fas fa-copy"
                    , isOpen = True
                    , subItems =
                        List.map
                            (\(Labels.DocumentLabel { ref, label }) -> label)
                            documentLabels
                            |> List.map folderMenuItem
                            |> List.foldl Dict.union Dict.empty
                    , addItem = Just AddDocumentsMenuItem
                    }
              )
            ]
    , team =
        Dict.fromList
            [ ( "team"
              , MenuItem
                    { icon = "fas fa-users"
                    , isOpen = True
                    , addItem = Just AddTeamMemberMenuItem
                    , subItems = List.map teamMemberMenuItem team |> List.foldl Dict.union Dict.empty
                    }
              )
            ]
    , labels =
        Dict.fromList
            [ ( "labels"
              , MenuItem
                    { isOpen = True
                    , icon = "fas fa-tags"
                    , addItem = Just AddLabelMenuItem
                    , subItems =
                        Dict.fromList
                            [ ( "document labels"
                              , MenuItem
                                    { icon = "fas fa-file"
                                    , isOpen = False
                                    , addItem = Nothing
                                    , subItems =
                                        List.map
                                            (\(Labels.DocumentLabel { ref, label }) -> label)
                                            documentLabels
                                            |> List.map labelMenuItem
                                            |> List.foldl Dict.union Dict.empty
                                    }
                              )
                            , ( "span labels"
                              , MenuItem
                                    { icon = "fas fa-highlighter"
                                    , isOpen = False
                                    , addItem = Nothing
                                    , subItems =
                                        List.map
                                            (\(Labels.SpanLabel { ref, label }) -> label)
                                            spanLabels
                                            |> List.map labelMenuItem
                                            |> List.foldl Dict.union Dict.empty
                                    }
                              )
                            , ( "relation labels"
                              , MenuItem
                                    { icon = "fas fa-link"
                                    , isOpen = False
                                    , addItem = Nothing
                                    , subItems =
                                        List.map
                                            (\(Labels.RelationLabel { ref, label }) -> label)
                                            relationLabels
                                            |> List.map labelMenuItem
                                            |> List.foldl Dict.union Dict.empty
                                    }
                              )
                            ]
                    }
              )
            ]
    }


getSubItems (MenuItem { subItems }) =
    Just subItems


setSubItems (MenuItem options) subItems =
    MenuItem { options | subItems = subItems }


getMenuItem : List String -> Dict.Dict String MenuItem -> Maybe MenuItem
getMenuItem labels subMenu =
    case labels of
        [] ->
            Nothing

        last :: [] ->
            Dict.get last subMenu

        first :: rest ->
            Dict.get first subMenu
                |> Maybe.andThen getSubItems
                |> Maybe.andThen (getMenuItem rest)


setMenuItem : MenuItem -> List String -> Dict.Dict String MenuItem -> Maybe (Dict.Dict String MenuItem)
setMenuItem newItem path subMenu =
    case path of
        [] ->
            Nothing

        last :: [] ->
            Just (Dict.insert last newItem subMenu)

        first :: rest ->
            Dict.get first subMenu
                |> Maybe.andThen getSubItems
                |> Maybe.andThen (setMenuItem newItem rest)
                |> Maybe.map2 setSubItems (Dict.get first subMenu)
                |> Maybe.andThen (\newSubSubMenu -> Just (Dict.insert first newSubSubMenu subMenu))


addLabel : List String -> String -> Menu -> Menu
addLabel path label menu =
    case getMenuItem path menu.labels of
        Just (MenuItem options) ->
            let
                { icon, subItems, addItem, isOpen } =
                    options

                labelItem =
                    MenuItem
                        { icon = "fas fa-tag"
                        , isOpen = False
                        , subItems = Dict.empty
                        , addItem = Nothing
                        }

                newSubItems =
                    Dict.insert
                        label
                        labelItem
                        subItems

                newLabels =
                    setMenuItem
                        (MenuItem { options | subItems = newSubItems })
                        path
                        menu.labels
                        |> Maybe.withDefault Dict.empty
            in
            { menu | labels = newLabels }

        Nothing ->
            Debug.todo "Either labels or a permanent subitem was removed from the menu"


addDocumentLabel : Labels.DocumentLabel -> Menu -> Menu
addDocumentLabel (Labels.DocumentLabel { ref, label }) menu =
    addLabel [ "labels", "document labels" ] label menu


addTeamMember : User.User -> Menu -> Menu
addTeamMember user menu =
    let
        menuItem =
            MenuItem { icon = "fas fa-user", isOpen = False, subItems = Dict.empty, addItem = Nothing }
    in
    case setMenuItem menuItem [ "team", user.email ] menu.team of
        Just newTeam ->
            { menu | team = newTeam }

        Nothing ->
            Debug.todo "team was removed from menu"


addSpanLabel : Labels.SpanLabel -> Menu -> Menu
addSpanLabel (Labels.SpanLabel { ref, label }) menu =
    addLabel [ "labels", "span labels" ] label menu


addRelationLabel : Labels.RelationLabel -> Menu -> Menu
addRelationLabel (Labels.RelationLabel { ref, label }) menu =
    addLabel [ "labels", "relation labels" ] label menu


folderMenuItem : String -> Dict.Dict String MenuItem
folderMenuItem documentLabel =
    Dict.fromList [ ( documentLabel, MenuItem { icon = "fas fa-folder", isOpen = False, subItems = Dict.empty, addItem = Nothing } ) ]


teamMemberMenuItem : String -> Dict.Dict String MenuItem
teamMemberMenuItem teamMember =
    Dict.fromList [ ( teamMember, MenuItem { icon = "fas fa-user", isOpen = False, subItems = Dict.empty, addItem = Nothing } ) ]


labelMenuItem : String -> Dict.Dict String MenuItem
labelMenuItem label =
    Dict.fromList [ ( label, MenuItem { icon = "fas fa-tag", isOpen = False, subItems = Dict.empty, addItem = Nothing } ) ]
