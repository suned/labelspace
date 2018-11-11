module AddLabelMenu exposing (labelType2String, modal, setLabel, setLabelType, setState, toggleIsOpen, update)

import ApiClient
import AppModel
import AppMsg
import Bulma
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Http


labelType2String labelType =
    case labelType of
        AppModel.Document ->
            "document label"

        AppModel.Span ->
            "span label"

        AppModel.Relation ->
            "relation label"


toggleIsOpen model =
    { model | isOpen = not model.isOpen }


setState state model =
    { model | state = state }


setLabel label model =
    { model | label = label }


setLabelType : AppModel.LabelType -> AppModel.AddLabelMenu -> AppModel.AddLabelMenu
setLabelType labelType model =
    { model | labelType = Just labelType }


update : AppMsg.AddLabelMenuMsg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        AppMsg.ToggleAddLabelMenu ->
            ( model |> AppModel.setAddLabelMenu AppModel.initAddLabelMenu, Cmd.none )

        AppMsg.SaveLabel ->
            ( model.addLabelMenu
                |> setState AppModel.AddLabelMenuPending
                |> AppModel.asAddLabelMenu model
            , case model.addLabelMenu.labelType of
                Just AppModel.Document ->
                    ApiClient.createLabel
                        model.apiUrl
                        model.token
                        (ApiClient.DocumentLabel { ref = Nothing, label = model.addLabelMenu.label })
                        (AppMsg.AddLabelMenuMsg
                            << AppMsg.Response
                        )

                Just AppModel.Span ->
                    ApiClient.createLabel
                        model.apiUrl
                        model.token
                        (ApiClient.SpanLabel { ref = Nothing, label = model.addLabelMenu.label })
                        (AppMsg.AddLabelMenuMsg
                            << AppMsg.Response
                        )

                Just AppModel.Relation ->
                    ApiClient.createLabel
                        model.apiUrl
                        model.token
                        (ApiClient.SpanLabel { ref = Nothing, label = model.addLabelMenu.label })
                        (AppMsg.AddLabelMenuMsg
                            << AppMsg.Response
                        )

                Nothing ->
                    Debug.todo "redesign this"
            )

        AppMsg.SetLabel label ->
            ( model.addLabelMenu |> setLabel label |> AppModel.asAddLabelMenu model, Cmd.none )

        AppMsg.Select labelType ->
            ( model.addLabelMenu |> setLabelType labelType |> AppModel.asAddLabelMenu model, Cmd.none )

        AppMsg.Response result ->
            case result of
                Ok label ->
                    ( AppModel.initAddLabelMenu
                        |> AppModel.asAddLabelMenu model
                        |> AppModel.addLabel label
                    , Cmd.none
                    )

                Err cause ->
                    let
                        _ =
                            Debug.log "cause" cause
                    in
                    ( model.addLabelMenu |> setState AppModel.AddLabelMenuError |> AppModel.asAddLabelMenu model, Cmd.none )


modal : AppModel.AddLabelMenu -> Html.Html AppMsg.Msg
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
                                                , Events.onClick (AppMsg.AddLabelMenuMsg (AppMsg.Select AppModel.Document))
                                                ]
                                                [ Html.span [ Bulma.iconClass ]
                                                    [ Html.i [ Attributes.class "fas fa-file" ] [] ]
                                                , Html.text (labelType2String AppModel.Document)
                                                ]
                                            , Html.option [ Attributes.value "span label", Events.onClick (AppMsg.AddLabelMenuMsg (AppMsg.Select AppModel.Span)) ]
                                                [ Html.span [ Bulma.iconClass ]
                                                    [ Html.i [ Attributes.class "fas fa-highlighter" ] [] ]
                                                , Html.text (labelType2String AppModel.Span)
                                                ]
                                            , Html.option [ Attributes.value "relation label", Events.onClick (AppMsg.AddLabelMenuMsg (AppMsg.Select AppModel.Relation)) ]
                                                [ Html.span [ Bulma.iconClass ]
                                                    [ Html.i [ Attributes.class "fas fa-link" ] [] ]
                                                , Html.text (labelType2String AppModel.Relation)
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

                                ( _, AppModel.AddLabelMenuPending, _ ) ->
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
                                AppModel.AddLabelMenuError ->
                                    []

                                _ ->
                                    [ Bulma.isInvisibleClass ]
                           )
                    )
                    [ Html.text "Something went wrong, try again later." ]
                ]
            ]
        ]
