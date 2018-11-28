module AddLabelMenuView exposing (labelType2String, modal, update)

import AddLabelMenu
import AppModel
import AppMsg
import AppSync
import Bulma
import Decoders
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Http
import Json.Decode
import Labels


labelType2String labelType =
    case labelType of
        AppMsg.Document ->
            "document label"

        AppMsg.Span ->
            "span label"

        AppMsg.Relation ->
            "relation label"


update : AppMsg.AddLabelMenuMsg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        AppMsg.ToggleAddLabelMenu ->
            ( model |> AppModel.setAddLabelMenu AddLabelMenu.init, Cmd.none )

        AppMsg.SaveLabel ->
            ( model.addLabelMenu
                |> AddLabelMenu.setState AddLabelMenu.Pending
                |> AppModel.asAddLabelMenu model
            , case model.addLabelMenu.labelType of
                Just AppMsg.Document ->
                    AppSync.send
                        (AppMsg.AddLabelMenuMsg << AppMsg.CreateDocumentLabelResponse)
                        (AppMsg.CreateDocumentLabelRequest { ref = Nothing, label = model.addLabelMenu.label })

                Just AppMsg.Span ->
                    AppSync.send
                        (AppMsg.AddLabelMenuMsg << AppMsg.CreateSpanLabelResponse)
                        (AppMsg.CreateSpanLabelRequest { ref = Nothing, label = model.addLabelMenu.label })

                Just AppMsg.Relation ->
                    AppSync.send
                        (AppMsg.AddLabelMenuMsg << AppMsg.CreateRelationLabelResponse)
                        (AppMsg.CreateRelationLabelRequest { ref = Nothing, label = model.addLabelMenu.label })

                Nothing ->
                    Debug.todo "Save label button clicked while no label type was selected. This shouldn't be possible: redesign."
            )

        AppMsg.SetLabel label ->
            ( model.addLabelMenu |> AddLabelMenu.setLabel label |> AppModel.asAddLabelMenu model, Cmd.none )

        AppMsg.Select labelType ->
            ( model.addLabelMenu |> AddLabelMenu.setLabelType (Just labelType) |> AppModel.asAddLabelMenu model, Cmd.none )

        AppMsg.CreateDocumentLabelResponse result ->
            handleCreateLabelResponse result model (AppModel.addDocumentLabel << Labels.DocumentLabel)

        AppMsg.CreateSpanLabelResponse result ->
            handleCreateLabelResponse result model (AppModel.addSpanLabel << Labels.SpanLabel)

        AppMsg.CreateRelationLabelResponse result ->
            handleCreateLabelResponse result model (AppModel.addRelationLabel << Labels.RelationLabel)


handleCreateLabelResponse : Result String Json.Decode.Value -> AppModel.Model -> (Labels.Label -> AppModel.Model -> AppModel.Model) -> ( AppModel.Model, Cmd AppMsg.Msg )
handleCreateLabelResponse result model labelAdder =
    case result of
        Err _ ->
            ( model.addLabelMenu
                |> AddLabelMenu.setState AddLabelMenu.Error
                |> AppModel.asAddLabelMenu model
            , Cmd.none
            )

        Ok json ->
            case Json.Decode.decodeValue Decoders.labelDecoder json of
                Err reason ->
                    ( model.addLabelMenu
                        |> AddLabelMenu.setState AddLabelMenu.Error
                        |> AppModel.asAddLabelMenu model
                    , Cmd.none
                    )

                Ok label ->
                    ( AddLabelMenu.init
                        |> AppModel.asAddLabelMenu (labelAdder label model)
                    , Cmd.none
                    )


modal : AddLabelMenu.AddLabelMenu -> Html.Html AppMsg.Msg
modal model =
    Html.div
        ([ Bulma.modalClass ]
            ++ (if model.isOpen then
                    [ Bulma.isActiveClass ]

                else
                    []
               )
        )
        [ Html.div [ Bulma.modalBackgroundClass ] []
        , Html.div [ Bulma.modalCardClass ]
            [ Html.header [ Bulma.modalCardHeadClass ]
                [ Html.p [ Bulma.modalCardTitleClass ] [ Html.text "Add Label" ]
                , Html.button
                    [ Bulma.deleteClass
                    , Events.onClick
                        (AppMsg.AddLabelMenuMsg
                            AppMsg.ToggleAddLabelMenu
                        )
                    ]
                    []
                ]
            , Html.section [ Bulma.modalCardBodyClass ]
                [ Html.div [ Bulma.fieldClass ]
                    [ Html.div [ Bulma.columnsClass ]
                        [ Html.div [ Bulma.columnClass, Bulma.isNarrowClass ]
                            [ Html.div [ Bulma.fieldClass ]
                                [ Html.label [ Bulma.labelClass ]
                                    [ Html.text "label type" ]
                                , Html.div [ Bulma.controlClass ]
                                    [ Html.div [ Bulma.selectClass, Bulma.isMultipleClass ]
                                        [ Html.select
                                            ([ Attributes.multiple True
                                             , Attributes.size 3
                                             ]
                                                ++ (case model.labelType of
                                                        Nothing ->
                                                            [ Attributes.value "" ]

                                                        Just labelType ->
                                                            [ Attributes.value (labelType2String labelType) ]
                                                   )
                                            )
                                            [ Html.option
                                                [ Attributes.value "document label"
                                                , Events.onClick (AppMsg.AddLabelMenuMsg (AppMsg.Select AppMsg.Document))
                                                ]
                                                [ Html.span [ Bulma.iconClass ]
                                                    [ Html.i [ Attributes.class "fas fa-file" ] [] ]
                                                , Html.text (labelType2String AppMsg.Document)
                                                ]
                                            , Html.option
                                                [ Attributes.value "span label"
                                                , Events.onClick (AppMsg.AddLabelMenuMsg (AppMsg.Select AppMsg.Span))
                                                ]
                                                [ Html.span [ Bulma.iconClass ]
                                                    [ Html.i [ Attributes.class "fas fa-highlighter" ] [] ]
                                                , Html.text (labelType2String AppMsg.Span)
                                                ]
                                            , Html.option
                                                [ Attributes.value "relation label"
                                                , Events.onClick (AppMsg.AddLabelMenuMsg (AppMsg.Select AppMsg.Relation))
                                                ]
                                                [ Html.span [ Bulma.iconClass ]
                                                    [ Html.i [ Attributes.class "fas fa-link" ] [] ]
                                                , Html.text (labelType2String AppMsg.Relation)
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        , Html.div [ Bulma.columnClass ]
                            [ Html.div [ Bulma.fieldClass ]
                                [ Html.label [ Bulma.labelClass ]
                                    [ Html.text "label" ]
                                , Html.div [ Bulma.controlClass ]
                                    [ Html.input
                                        [ Bulma.inputClass
                                        , Attributes.placeholder "label"
                                        , Attributes.value model.label
                                        , Events.onInput (AppMsg.AddLabelMenuMsg << AppMsg.SetLabel)
                                        ]
                                        []
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            , Html.footer [ Bulma.modalCardFootClass ]
                [ Html.button
                    ([ Bulma.buttonClass
                     , Bulma.isSuccessClass
                     , Events.onClick (AppMsg.AddLabelMenuMsg AppMsg.SaveLabel)
                     ]
                        ++ (case ( model.label, model.state, model.labelType ) of
                                ( "", _, _ ) ->
                                    [ Attributes.disabled True ]

                                ( _, _, Nothing ) ->
                                    [ Attributes.disabled True ]

                                ( _, AddLabelMenu.Pending, _ ) ->
                                    [ Bulma.isLoadingClass ]

                                _ ->
                                    []
                           )
                    )
                    [ Html.text "save" ]
                , Html.span
                    ([ Bulma.helpClass
                     , Bulma.isDangerClass
                     ]
                        ++ (case model.state of
                                AddLabelMenu.Error ->
                                    []

                                _ ->
                                    [ Bulma.isInvisibleClass ]
                           )
                    )
                    [ Html.text "Something went wrong, try again later." ]
                ]
            ]
        ]
