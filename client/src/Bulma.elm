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
navBarItemClass = Attributes.class "navbar-item"
isPrimaryClass = Attributes.class "is-primary"
navBarClass = Attributes.class "navbar"
navBarBrandClass = Attributes.class "navbar-brand"
navbarMenuClass = Attributes.class "navbar-menu"
navbarStartClass = Attributes.class "navbar-start"
navbarEndClass = Attributes.class "navbar-end"
isActiveClass = Attributes.class "is-active"
isLoadingClass = Attributes.class "is-loading"
isDisabledClass = Attributes.class "is-disabled"





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

navbarItem : List (Html.Attribute a) -> String -> String -> Html a
navbarItem attributes path label =
    Html.a ([ navBarItemClass, Attributes.href path ] ++ attributes) [ Html.text label ]

navbar : Html a -> List (Html a) -> Html a
navbar brand navbarItems =
    Html.nav [ navBarClass, isPrimaryClass ]
        [ brand
        , Html.div [ navbarMenuClass ]
            [ Html.div [ navbarStartClass ] []
            , Html.div [ navbarEndClass ]
                navbarItems
            ]
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