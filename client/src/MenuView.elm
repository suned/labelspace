module MenuView exposing
    ( closedMenu
    , encode
    , fileInputId
    , menu
    , menuToggleHoverStyle
    , openMenu
    , setMenu
    , update
    )

import AddLabelMenu
import AddLabelMenuView
import AddTeamMemberMenu
import AddTeamMemberMenuView
import AppModel
import AppMsg
import AppSync
import AttributeBuilder
import Bulma
import Css
import Dict
import Document
import Editor
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Labels
import Menu
import Ports
import User


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


addDocumentsHtml : Maybe Float -> Html.Html AppMsg.Msg
addDocumentsHtml state =
    case state of
        Nothing ->
            Html.div []
                [ Html.input
                    [ Attributes.id fileInputId
                    , Attributes.type_ "file"
                    , Attributes.multiple True
                    , Attributes.accept ".doc,.docx,.html,.odt,.pages,.pdf,.rtf,.txt"
                    , Attributes.css [ Css.display Css.none ]
                    , Events.on "change" (Decode.succeed (AppMsg.MenuMsg Menu.ToggleAddDocumentsMenu))
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

        Just percent ->
            Html.li
                []
                [ Html.a
                    [ Attributes.href "" ]
                    [ Html.progress
                        [ Attributes.value (String.fromFloat percent)
                        , Bulma.isLinkClass
                        , Bulma.progressClass
                        , Bulma.isSmall
                        , Attributes.max "1.0"
                        ]
                        []
                    ]
                ]


icon iconType =
    Html.span [ Bulma.iconClass ] [ Html.i [ Attributes.class iconType ] [] ]


documentHtml : Maybe Document.Document -> Document.Document -> Html.Html AppMsg.Msg
documentHtml openDocument document =
    case openDocument of
        Just d ->
            Html.li
                []
                [ Html.a
                    ([ Attributes.href ""
                     ]
                        |> AttributeBuilder.addIf
                            (document == d)
                            [ Bulma.isActiveClass ]
                        |> AttributeBuilder.addIf
                            (not <| document == d)
                            [ document |> Menu.OpenDocument |> AppMsg.MenuMsg |> Events.onClick ]
                    )
                    [ icon "fas fa-file"
                    , Html.text document.name
                    ]
                ]

        Nothing ->
            Html.li
                []
                [ Html.a
                    [ Attributes.href ""
                    , document |> Menu.OpenDocument |> AppMsg.MenuMsg |> Events.onClick
                    ]
                    [ icon "fas fa-file"
                    , Html.text document.name
                    ]
                ]


documentsHtml : AppModel.Model -> List (Html.Html AppMsg.Msg)
documentsHtml model =
    List.map (documentHtml model.openDocument) model.documents


documentsMenuHtml : AppModel.Model -> Html.Html AppMsg.Msg
documentsMenuHtml model =
    let
        subMenuHtml =
            if model.menu.documents.isOpen then
                [ Html.ul []
                    ([ addDocumentsHtml model.menu.documents.uploadState
                     ]
                        ++ documentsHtml model
                    )
                ]

            else
                []
    in
    Html.li
        []
        ([ Html.a
            [ Attributes.href ""
            , Events.onClick (AppMsg.MenuMsg Menu.ToggleDocumentsMenu)
            ]
            [ icon "fas fa-copy"
            , Html.text "documents"
            ]
         ]
            ++ subMenuHtml
        )


labelsHtml : Labels.Label -> Html.Html AppMsg.Msg
labelsHtml label =
    Html.li [] [ Html.a [ Attributes.href "" ] [ icon "fas fa-tag", Html.text label.label ] ]


addLabelMenuHtml =
    Html.li []
        [ Html.a
            [ Attributes.href ""
            , Bulma.hasTextLinkClass
            , Events.onClick (AppMsg.MenuMsg Menu.ToggleAddLabelMenu)
            ]
            [ Html.span [ Bulma.iconClass ]
                [ Html.i [ Attributes.class "fas fa-plus" ] [] ]
            , Html.text "add"
            ]
        ]


labelsMenuHtml : AppModel.Model -> Html.Html AppMsg.Msg
labelsMenuHtml model =
    let
        spanLabelsHtml =
            if
                model.menu.labels.spanLabelsIsOpen
                    && not (List.isEmpty model.spanLabels)
            then
                [ Html.ul
                    []
                    (model.spanLabels
                        |> List.map (\(Labels.SpanLabel label) -> label)
                        |> List.map labelsHtml
                    )
                ]

            else
                []

        relationLabelsHtml =
            if
                model.menu.labels.relationLabelsIsOpen
                    && not (List.isEmpty model.relationLabels)
            then
                [ Html.ul []
                    (model.relationLabels
                        |> List.map (\(Labels.RelationLabel label) -> label)
                        |> List.map labelsHtml
                    )
                ]

            else
                []

        documentLabelsHtml =
            if
                model.menu.labels.documentLabelsIsOpen
                    && not (List.isEmpty model.documentLabels)
            then
                [ Html.ul []
                    (model.documentLabels
                        |> List.map (\(Labels.DocumentLabel label) -> label)
                        |> List.map labelsHtml
                    )
                ]

            else
                []

        subMenuHtml =
            if model.menu.labels.isOpen then
                [ Html.ul
                    []
                    [ addLabelMenuHtml
                    , Html.li
                        []
                        ([ Html.a
                            [ Attributes.href ""
                            , Events.onClick (AppMsg.MenuMsg Menu.ToggleSpanLabelsMenu)
                            ]
                            [ icon "fas fa-highlighter"
                            , Html.text "span labels"
                            ]
                         ]
                            ++ spanLabelsHtml
                        )
                    , Html.li
                        []
                        ([ Html.a
                            [ Attributes.href ""
                            , Events.onClick (AppMsg.MenuMsg Menu.ToggleRelationLabelsMenu)
                            ]
                            [ icon "fas fa-link"
                            , Html.text "relation labels"
                            ]
                         ]
                            ++ relationLabelsHtml
                        )
                    , Html.li
                        []
                        ([ Html.a
                            [ Attributes.href ""
                            , Events.onClick (AppMsg.MenuMsg Menu.ToggleDocumentsLabelMenu)
                            ]
                            [ icon "fas fa-file"
                            , Html.text "document labels"
                            ]
                         ]
                            ++ documentLabelsHtml
                        )
                    ]
                ]

            else
                []
    in
    Html.li
        []
        ([ Html.a
            [ Attributes.href ""
            , Events.onClick (AppMsg.MenuMsg Menu.ToggleLabelsMenu)
            ]
            [ icon "fas fa-tags"
            , Html.text "labels"
            ]
         ]
            ++ subMenuHtml
        )


teamMemberHtml : User.User -> Html.Html AppMsg.Msg
teamMemberHtml teamMember =
    Html.li []
        [ Html.a
            [ Attributes.href "" ]
            [ icon "fas fa-user", Html.text teamMember.email ]
        ]


addTeamMemberHtml =
    Html.li []
        [ Html.a
            [ Attributes.href ""
            , Bulma.hasTextLinkClass
            , Events.onClick (AppMsg.MenuMsg Menu.ToggleAddTeamMemberMenu)
            ]
            [ Html.span [ Bulma.iconClass ]
                [ Html.i [ Attributes.class "fas fa-plus" ] [] ]
            , Html.text "add"
            ]
        ]


teamMenuHtml : AppModel.Model -> Html.Html AppMsg.Msg
teamMenuHtml model =
    let
        subMenuHtml =
            if model.menu.team.isOpen then
                [ Html.ul
                    []
                    ([ addTeamMemberHtml ] ++ List.map teamMemberHtml model.teamMembers)
                ]

            else
                []
    in
    Html.li
        []
        ([ Html.a
            [ Attributes.href ""
            , Events.onClick (AppMsg.MenuMsg Menu.ToggleTeamMenu)
            ]
            [ icon "fas fa-users", Html.text "team" ]
         ]
            ++ subMenuHtml
        )


openMenu : AppModel.Model -> Html.Html AppMsg.Msg
openMenu model =
    Html.div [ Bulma.columnsClass, Bulma.isGapless ]
        [ Html.div [ Bulma.columnClass, Bulma.is11, Bulma.isClipped, Attributes.css [ Css.whiteSpace Css.noWrap ] ]
            [ Html.aside [ Bulma.menuClass ]
                [ Html.ul [ Bulma.menuListClass ]
                    [ documentsMenuHtml model
                    , labelsMenuHtml model
                    , teamMenuHtml model
                    ]
                ]
            ]
        , Html.div [ Bulma.columnClass, Bulma.isNarrowClass ]
            [ Html.span [ Bulma.iconClass, Events.onClick (AppMsg.MenuMsg Menu.ToggleMenu), Bulma.isPulledRightClass, menuToggleHoverStyle ]
                [ Html.i [ Attributes.class "fas fa-angle-double-left" ] [] ]
            ]
        ]


closedMenu =
    Html.aside [ Bulma.menuClass ]
        [ Html.span
            [ Bulma.iconClass
            , Events.onClick (AppMsg.MenuMsg Menu.ToggleMenu)
            , menuToggleHoverStyle
            ]
            [ Html.i [ Attributes.class "fas fa-angle-double-right" ] [] ]
        ]


setMenu menuModel model =
    { model | menu = menuModel }


update : Menu.MenuMsg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        Menu.ToggleAddDocumentsMenu ->
            ( model.menu
                |> Menu.setUploadProgress 0.0
                |> AppModel.asMenu model
            , Ports.upload (encode model)
            )

        Menu.ToggleAddLabelMenu ->
            let
                newAddLabelMenuModel =
                    AddLabelMenu.toggleIsOpen model.addLabelMenu
            in
            ( { model | addLabelMenu = newAddLabelMenuModel }, Cmd.none )

        Menu.ToggleAddTeamMemberMenu ->
            let
                newAddTeamMemberMenu =
                    AddTeamMemberMenu.toggle model.addTeamMemberMenu
            in
            ( { model | addTeamMemberMenu = newAddTeamMemberMenu }, Cmd.none )

        Menu.ToggleMenu ->
            let
                newMenu =
                    model.menu |> (\m -> { m | isOpen = not m.isOpen })
            in
            ( { model | menu = newMenu }, Cmd.none )

        Menu.UploadProgress percent ->
            if percent == 1.0 then
                ( model.menu
                    |> Menu.finishUpload
                    |> AppModel.asMenu model
                , Cmd.none
                )

            else
                ( model.menu
                    |> Menu.setUploadProgress percent
                    |> AppModel.asMenu model
                , Cmd.none
                )

        Menu.OpenDocument document ->
            ( model.editor |> Editor.setState Editor.Pending |> AppModel.asEditor { model | openDocument = Just document }
            , AppSync.send
                (AppMsg.EditorMsg << AppMsg.GetDocumentLinkResponse)
                (AppMsg.GetDocumentLinkRequest document)
            )

        Menu.ToggleDocumentsMenu ->
            ( model.menu |> Menu.toggleDocumentsMenu |> AppModel.asMenu model, Cmd.none )

        Menu.ToggleLabelsMenu ->
            ( model.menu |> Menu.toggleLabelsMenu |> AppModel.asMenu model, Cmd.none )

        Menu.ToggleSpanLabelsMenu ->
            ( model.menu |> Menu.toggleSpanLabelsMenu |> AppModel.asMenu model, Cmd.none )

        Menu.ToggleRelationLabelsMenu ->
            ( model.menu |> Menu.toggleRelationLabelsMenu |> AppModel.asMenu model, Cmd.none )

        Menu.ToggleDocumentsLabelMenu ->
            ( model.menu |> Menu.toggleDocumentLabelsMenu |> AppModel.asMenu model, Cmd.none )

        Menu.ToggleTeamMenu ->
            ( model.menu |> Menu.toggleTeamMenu |> AppModel.asMenu model, Cmd.none )


menu : AppModel.Model -> Html.Html AppMsg.Msg
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
        [ AddLabelMenuView.modal model.addLabelMenu
        , AddTeamMemberMenuView.modal model.addTeamMemberMenu
        , if model.menu.isOpen then
            openMenu model

          else
            closedMenu
        ]
