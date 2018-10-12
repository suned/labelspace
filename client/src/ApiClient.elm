module ApiClient exposing(..)
import Http
import Url.Builder as Builder
import Json.Decode as Decode
import Json.Encode as Encode

type alias LabelData =
  { ref: Maybe String, label: String }

type Label
  = DocumentLabel LabelData
  | SpanLabel LabelData
  | RelationLabel LabelData

maybeEncoder : (a -> Encode.Value) -> Maybe a -> Encode.Value
maybeEncoder value maybe =
  case maybe of
    Just v -> value v
    Nothing -> Encode.null

labelEncoder : LabelData -> Encode.Value
labelEncoder label =
  Encode.object
    [ ("label", Encode.string label.label)
    , ("ref", maybeEncoder Encode.string label.ref)
    ]

labelDecoder : (LabelData -> Label) -> Decode.Decoder Label
labelDecoder label =
  Decode.map
    label
    (Decode.map2
      LabelData
      ( Decode.nullable ( Decode.field "ref" Decode.string ) )
      ( Decode.field "label" Decode.string ))

createLabelRequest : String -> String -> LabelData -> String -> (LabelData -> Label) -> Http.Request Label
createLabelRequest apiRootUrl token labelData labelPath labelType =
  Http.request
    { method = "POST"
    , headers = [Http.header "Authorization" token]
    , url = Builder.crossOrigin apiRootUrl ["labels", labelPath] []
    , body = Http.jsonBody (labelEncoder labelData)
    , expect = Http.expectJson (labelDecoder labelType)
    , timeout = Nothing
    , withCredentials = False
    }

createLabel : String -> String -> Label -> (Result Http.Error Label -> msg) -> Cmd msg
createLabel apiRootUrl token label msg =
  case label of
    DocumentLabel data ->
      Http.send
      msg
      (createLabelRequest apiRootUrl token data "document" DocumentLabel)
    SpanLabel data ->
      Http.send
      msg
      (createLabelRequest apiRootUrl token data "span" SpanLabel)
    RelationLabel data ->
      Http.send
      msg
      (createLabelRequest apiRootUrl token data "span" RelationLabel)
