module LoginData exposing (LoginData)

import Document
import Labels
import User


type alias LoginData =
    { token : String
    , team : List User.User
    , documents : List Document.Document
    , spanLabels : List Labels.SpanLabel
    , documentLabels : List Labels.DocumentLabel
    , relationLabels : List Labels.RelationLabel
    }
