module EditorView exposing (editor, update)

import AppModel
import AppMsg
import Bulma
import Css
import Editor
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Json.Decode


editor model =
    case model.editor.state of
        Editor.Init ->
            Html.div
                [ Bulma.columnClass ]
                [ Html.div
                    [ Bulma.sectionClass ]
                    [ Html.h1
                        [ Bulma.titleClass ]
                        [ Html.text "Welcome to labelspace!" ]
                    ]
                ]

        Editor.Ready html ->
            Html.div [ Bulma.columnClass ] [ Html.iframe [ Bulma.sectionClass, Attributes.css [ Css.width <| Css.pct 100.0, Css.height <| Css.pct 100.0 ], Attributes.srcdoc html ] [] ]

        Editor.Pending ->
            Html.div
                [ Bulma.columnClass ]
                [ Html.div
                    [ Bulma.sectionClass ]
                    [ Html.h1 [ Bulma.titleClass ] [ Html.text "Loading..." ] ]
                ]


update : AppMsg.EditorMsg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        AppMsg.GetDocumentLinkResponse result ->
            case result of
                Err _ ->
                    Debug.todo ""

                Ok json ->
                    case Json.Decode.decodeValue Json.Decode.string json of
                        Err reason ->
                            Debug.todo ""

                        Ok html ->
                            ( model.editor |> Editor.setState (Editor.Ready html) |> AppModel.asEditor model, Cmd.none )
