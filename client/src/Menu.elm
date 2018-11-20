module Menu exposing
    ( addDocumentMenuItem
    , addMenuItem
    , addSubItems
    , closedMenu
    , encode
    , fileInputId
    , menu
    , menuItemHtml
    , menuToggleHoverStyle
    , openMenu
    , setMenu
    , toggleAddLabelModal
    , toggleMenu
    , toggleMenuItem
    , update
    )

import AddLabelMenu
import AppModel
import Bulma
import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Ports


fileInputId =
    "fileInput"


encode : AppModel.Model -> Encode.Value
encode model =
    Encode.object
        [ ( "id", Encode.string fileInputId )
        , ( "token", Encode.string model.token )
        ]


menuToggleHoverStyle =
    Attributes.css
        [ Css.cursor Css.pointer
        , Css.hover [ Css.color (Css.hex "3273dc") ]
        ]


addDocumentMenuItem =
    Html.div []
        [ Html.input
            [ Attributes.id fileInputId
            , Attributes.type_ "file"
            , Attributes.css [ Css.display Css.none ]
            , Events.on "change" (Decode.succeed (AppModel.MenuMsg (AppModel.ToggleAddMenu AppModel.AddDocumentsMenuItem)))
            ]
            []
        , Html.label [ Attributes.for fileInputId ]
            [ Html.li []
                {- This should really be an <a> tag in order for bulma styling to appear
                   Correctly. I couldn't get the label to trigger the file input
                   when wrapping the <a> tag However, so instead I'm using a span and
                   replicating the styles applied by Bulma here :(
                -}
                [ Html.span
                    [ Bulma.hasTextLinkClass
                    , Attributes.css
                        [ Css.padding2 (Css.em 0.5) (Css.em 0.75)
                        , Css.display Css.block
                        , Css.cursor Css.pointer
                        , Css.hover [ Css.backgroundColor (Css.hex "F5F5F5") ]
                        ]
                    ]
                    [ Html.span [ Bulma.iconClass ]
                        [ Html.i [ Attributes.class "fas fa-plus" ] [] ]
                    , Html.text "add"
                    ]
                ]
            ]
        ]


addMenuItem addMenuItemType =
    Html.li []
        [ Html.a
            [ Attributes.href ""
            , Bulma.hasTextLinkClass
            , Events.onClick (AppModel.MenuMsg (AppModel.ToggleAddMenu addMenuItemType))
            ]
            [ Html.span [ Bulma.iconClass ]
                [ Html.i [ Attributes.class "fas fa-plus" ] [] ]
            , Html.text "add"
            ]
        ]


addSubItems addItem subItems =
    let
        subMenuHtml =
            List.map menuItemHtml subItems
    in
    case addItem of
        Just AppModel.AddDocumentsMenuItem ->
            [ Html.ul []
                ([ addDocumentMenuItem ] ++ subMenuHtml)
            ]

        Just addMenuItemType ->
            [ Html.ul []
                ([ addMenuItem addMenuItemType ] ++ subMenuHtml)
            ]

        Nothing ->
            [ Html.ul [] subMenuHtml ]


menuItemHtml : AppModel.MenuItem -> Html.Html AppModel.Msg
menuItemHtml menuItem =
    case menuItem of
        AppModel.MenuItem { label, icon, isOpen, addItem, subItems } ->
            Html.li []
                ([ Html.a
                    ([ Attributes.href ""
                     ]
                        ++ (case ( subItems, addItem ) of
                                ( [], Nothing ) ->
                                    []

                                _ ->
                                    [ Events.onClick (AppModel.MenuMsg (AppModel.ToggleMenuItem menuItem)) ]
                           )
                    )
                    [ Html.span [ Bulma.iconClass ]
                        [ Html.i [ Attributes.class icon ] [] ]
                    , Html.text label
                    ]
                 ]
                    ++ (if isOpen then
                            addSubItems addItem subItems

                        else
                            []
                       )
                )


labelMenuHtml : AppModel.LabelMenu -> Html.Html AppModel.Msg
labelMenuHtml labelMenu =
    let
        labelMenuItem =
            AppModel.MenuItem
                { addItem = Just AppModel.AddLabelMenuItem
                , label = "labels"
                , icon = "fas fa-tags"
                , subItems =
                    [ labelMenu.documentLabels
                    , labelMenu.spanLabels
                    , labelMenu.relationLables
                    ]
                , isOpen = labelMenu.isOpen
                }
    in
    menuItemHtml labelMenuItem


openMenu : AppModel.Model -> Html.Html AppModel.Msg
openMenu model =
    Html.div [ Bulma.columnsClass ]
        [ Html.div [ Bulma.columnClass ]
            [ Html.aside [ Bulma.menuClass ]
                [ Html.ul [ Bulma.menuListClass ]
                    [ menuItemHtml model.menu.documents
                    , labelMenuHtml model.menu.labels
                    , menuItemHtml model.menu.team
                    ]
                ]
            ]
        , Html.div [ Bulma.columnClass, Bulma.isNarrowClass ]
            [ Html.span [ Bulma.iconClass, Events.onClick (AppModel.MenuMsg AppModel.ToggleMenu), Bulma.isPulledRightClass, menuToggleHoverStyle ]
                [ Html.i [ Attributes.class "fas fa-angle-double-left" ] [] ]
            ]
        ]


closedMenu =
    Html.aside [ Bulma.menuClass ]
        [ Html.span
            [ Bulma.iconClass
            , Events.onClick (AppModel.MenuMsg AppModel.ToggleMenu)
            , menuToggleHoverStyle
            ]
            [ Html.i [ Attributes.class "fas fa-angle-double-right" ] [] ]
        ]


setMenu menuModel model =
    { model | menu = menuModel }


toggleMenuItem : AppModel.MenuItem -> AppModel.MenuItem -> AppModel.MenuItem
toggleMenuItem targetMenuItem menuItem =
    case ( targetMenuItem, menuItem ) of
        ( AppModel.MenuItem target, AppModel.MenuItem old ) ->
            if target == old then
                AppModel.MenuItem { old | isOpen = not old.isOpen, subItems = List.map (toggleMenuItem targetMenuItem) old.subItems }

            else
                AppModel.MenuItem { old | subItems = List.map (toggleMenuItem targetMenuItem) old.subItems }


toggleMenu : AppModel.Menu -> AppModel.MenuItem -> AppModel.Menu
toggleMenu menuModel menuItem =
    let
        toggledDocuments =
            toggleMenuItem menuItem menuModel.documents

        toggledTeam =
            toggleMenuItem menuItem menuModel.team

        toggledDocumentLabels =
            toggleMenuItem menuItem menuModel.labels.documentLabels

        toggledSpanLabels =
            toggleMenuItem menuItem menuModel.labels.spanLabels

        toggledRelationLabels =
            toggleMenuItem menuItem menuModel.labels.relationLables

        oldLabelsMenu =
            menuModel.labels

        newLabelsMenu =
            { oldLabelsMenu | documentLabels = toggledDocumentLabels, spanLabels = toggledSpanLabels, relationLables = toggledRelationLabels }
    in
    { menuModel | documents = toggledDocuments, labels = newLabelsMenu, team = toggledTeam }


toggleAddLabelModal model =
    { model | showLabelModal = not model.showLabelModal }


update msg model =
    case msg of
        AppModel.ToggleAddMenu AppModel.AddDocumentsMenuItem ->
            ( model, Ports.upload (encode model) )

        AppModel.ToggleAddMenu AppModel.AddLabelMenuItem ->
            let
                newAddLabelMenuModel =
                    AddLabelMenu.toggleIsOpen model.addLabelMenu
            in
            ( { model | addLabelMenu = newAddLabelMenuModel }, Cmd.none )

        AppModel.ToggleMenu ->
            let
                newMenu =
                    model.menu |> (\m -> { m | isOpen = not m.isOpen })
            in
            ( { model | menu = newMenu }, Cmd.none )

        AppModel.ToggleMenuItem menuItem ->
            ( model |> setMenu (toggleMenu model.menu menuItem), Cmd.none )

        _ ->
            ( model, Cmd.none )


menu : AppModel.Model -> Html.Html AppModel.Msg
menu model =
    Html.div
        [ Bulma.columnClass
        , if model.menu.isOpen then
            Bulma.is4

          else
            Bulma.isNarrowClass
        , Bulma.boxClass
        , Attributes.css [ Css.paddingLeft (Css.pct 2), Css.paddingTop (Css.pct 2) ]
        , Attributes.class "is-margin-less"
        , Attributes.css [ Css.minHeight (Css.calc (Css.vh 100) Css.minus (Css.em 2.5)) ]
        ]
        [ AddLabelMenu.modal model.addLabelMenu
        , if model.menu.isOpen then
            openMenu model

          else
            closedMenu
        ]
