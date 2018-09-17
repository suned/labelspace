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
fileClass = Attributes.class "file"
fileLabelClass = Attributes.class "file-label"
fileInputClass = Attributes.class "file-input"
fileCtaClass = Attributes.class "file-cta"
fileIconClass = Attributes.class "file-icon"
fasFaUploadClass = Attributes.class "fas fa-upload"




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

file : List (Html.Attribute a) -> String -> Html a
file attributes label =
    Html.div [ fileClass ] 
        [ Html.label [ fileLabelClass ]
            [ Html.input [ fileInputClass, Attributes.type_ "file"]
                []
            , Html.span [ fileCtaClass ]
                [ Html.span [ fileIconClass ]
                    [ Html.i [ fasFaUploadClass ]
                        []
                    ]
                , Html.span [ fileLabelClass ]
                    [ Html.text label ]
                ]
            ]
        ]


textInput : List (Html.Attribute a) -> Html a
textInput attributes =
    Html.input ([ inputClass, Attributes.type_ "text" ] ++ attributes) []


passwordInput : List (Html.Attribute a) -> Html a
passwordInput attributes =
    Html.input ([ inputClass, Attributes.type_ "password", Attributes.placeholder "password" ] ++ attributes) []