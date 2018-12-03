module AttributeBuilder exposing (addIf)

import Html.Styled as Html


addIf : Bool -> List (Html.Attribute msg) -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addIf predicate attributes previousAttributes =
    if predicate then
        attributes ++ previousAttributes

    else
        previousAttributes
