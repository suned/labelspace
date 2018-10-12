module AddLabelMenu exposing (..)

import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Bulma
import ApiClient
import Http


type Msg
  = Toggle
  | SetLabel String
  | Select LabelType
  | Save
  | CreateLabel (Result Http.Error ApiClient.Label)

type State
  = Init
  | Pending
  | Error

labelType2String labelType =
  case labelType of
    Document -> "document label"
    Span -> "span label"
    Relation -> "relation label"

type LabelType
  = Document
  | Span
  | Relation

type alias Model =
  { isOpen: Bool
  , labelType: Maybe LabelType
  , label: String
  , state: State
  , apiUrl: String
  , token: String
  }

setToken token model =
  { model | token = token }

toggleIsOpen model =
  { model | isOpen = not model.isOpen }

setState state model =
  { model | state = state }

setLabel label model =
  { model | label = label }

setLabelType : LabelType -> Model -> Model
setLabelType labelType model =
  { model | labelType = Just labelType }

initModel apiUrl token =
  Model False Nothing "" Init apiUrl token

update : Model -> Msg -> (Model, Cmd Msg)
update model msg =
  case msg of
    Toggle -> (initModel model.apiUrl model.token, Cmd.none)
    Save ->
      ( model |> setState Pending
      , case model.labelType of
          Just Document ->
            ApiClient.createLabel
              model.apiUrl
              model.token
              (ApiClient.DocumentLabel {ref = Nothing, label = model.label})
              CreateLabel
          Just Span ->
            ApiClient.createLabel
            model.apiUrl
            model.token
            (ApiClient.SpanLabel {ref = Nothing, label = model.label})
            CreateLabel
          Just Relation ->
            ApiClient.createLabel
            model.apiUrl
            model.token
            (ApiClient.SpanLabel {ref = Nothing, label = model.label})
            CreateLabel
          Nothing -> Debug.todo "redesign this"
      )
    SetLabel label -> (model |> setLabel label, Cmd.none)
    Select labelType -> (model |> setLabelType labelType, Cmd.none)
    CreateLabel result ->
      case result of
        Ok label -> (model, Cmd.none)
        Err _ -> (model |> setState Error, Cmd.none)

modal : Model -> Html.Html Msg
modal model =
  Html.div
    ([ Bulma.modalClass ] ++ if model.isOpen
      then [ Bulma.isActiveClass ]
      else [])
    [ Html.div [ Bulma.modalBackgroundClass ] []
    , Html.div [ Bulma.modalCardClass ]
      [ Html.header [ Bulma.modalCardHeadClass ]
        [ Html.p [ Bulma.modalCardTitleClass ] [ Html.text "Add Label" ]
        , Html.button [ Bulma.deleteClass, Events.onClick (Toggle) ] []
        ]
      , Html.section [ Bulma.modalCardBodyClass]
        [ Html.div [ Bulma.fieldClass]
          [ Html.div [ Bulma.columnsClass ]
            [ Html.div [ Bulma.columnClass, Bulma.isNarrowClass ]
              [ Html.div [ Bulma.fieldClass ]
                [ Html.label [ Bulma.labelClass ]
                  [ Html.text "label type" ]
                , Html.div [ Bulma.controlClass ]
                  [Html.div [ Bulma.selectClass, Bulma.isMultipleClass ]
                    [Html.select
                      ([ Attributes.multiple True
                       , Attributes.size 3
                       ] ++ case model.labelType of
                        Nothing -> [ Attributes.value ""]
                        Just labelType -> [Attributes.value (labelType2String labelType)])
                      [ Html.option [ Attributes.value "document label", Events.onClick (Select Document)]
                        [ Html.span [ Bulma.iconClass ]
                          [ Html.i [Attributes.class "fas fa-file"] []]
                        , Html.text (labelType2String Document)
                        ]
                      , Html.option [Attributes.value "span label", Events.onClick (Select Span)]
                        [ Html.span [ Bulma.iconClass ]
                          [ Html.i [Attributes.class "fas fa-highlighter"] []]
                        , Html.text (labelType2String Span)
                        ]
                      , Html.option [Attributes.value "relation label", Events.onClick (Select Relation)]
                        [ Html.span [ Bulma.iconClass ]
                          [ Html.i [Attributes.class "fas fa-link"] []]
                        , Html.text (labelType2String Relation)
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            , Html.div [Bulma.columnClass]
              [ Html.div [Bulma.fieldClass]
                [ Html.label [ Bulma.labelClass ]
                  [Html.text "label"]
                , Html.div [ Bulma.controlClass ]
                  [ Html.input
                    [ Bulma.inputClass
                    , Attributes.placeholder "label"
                    , Attributes.value model.label
                    , Events.onInput SetLabel
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
          , Events.onClick Save
          ] ++ case (model.label, model.state, model.labelType) of
            ("", _, _) -> [ Attributes.disabled True ]
            (_, _, Nothing) -> [ Attributes.disabled True ]
            (_, Pending, _) -> [ Bulma.isLoadingClass ]
            _ -> [])
          [Html.text "save"]
        ]
      ]
    ]
