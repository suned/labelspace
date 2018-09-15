module Bulma exposing (..)

import Html exposing (Html)
import Html.Attributes as Attributes



sectionClass = Attributes.class "section"
titleClass = Attributes.class "title"
subtitleClass = Attributes.class "subtitle"
containerClass = Attributes.class "container"
fieldClass = Attributes.class "field"
labelClass = Attributes.class "label"
controlClass = Attributes.class "control"
inputClass = Attributes.class "input"
isLinkClass = Attributes.class "is-link"
buttonClass = Attributes.class "button"


section : List (Html a) -> Html a
section children =
    Html.div [ sectionClass ]
        [ Html.div [ containerClass ] children ]


labelledField : String -> Html a -> Html a
labelledField label form =
    Html.div [ fieldClass ]
        [ Html.label [ labelClass ]
            [ Html.text label ]
        , Html.div [ controlClass ]
            [ form ]
        ]


field : Html a -> Html a
field form =
    Html.div [ fieldClass ]
        [ Html.div [ controlClass ]
            [ form ]
        ]


button : List (Html.Attribute a) -> String -> Html a
button attributes label =
    Html.button ([ buttonClass ] ++ attributes) [ Html.text label ]


textInput : List (Html.Attribute a) -> Html a
textInput attributes =
    Html.input ([ inputClass, Attributes.type_ "text" ] ++ attributes) []


passwordInput : List (Html.Attribute a) -> Html a
passwordInput attributes =
    Html.input ([ inputClass, Attributes.type_ "password", Attributes.placeholder "password" ] ++ attributes) []