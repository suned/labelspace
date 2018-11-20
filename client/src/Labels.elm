module Labels exposing (DocumentLabel(..), Label, RelationLabel(..), SpanLabel(..))


type alias Label =
    { ref : Maybe String, label : String }


type DocumentLabel
    = DocumentLabel Label


type SpanLabel
    = SpanLabel Label


type RelationLabel
    = RelationLabel Label
