module Bulma exposing (..)

import Html.Styled as Html
import Html.Styled.Attributes as Attributes



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
navbarItemClass = Attributes.class "navbar-item"
isPrimaryClass = Attributes.class "is-primary"
navBarClass = Attributes.class "navbar"
navBarBrandClass = Attributes.class "navbar-brand"
navbarMenuClass = Attributes.class "navbar-menu"
navbarStartClass = Attributes.class "navbar-start"
navbarEndClass = Attributes.class "navbar-end"
isActiveClass = Attributes.class "is-active"
isLoadingClass = Attributes.class "is-loading"
isDisabledClass = Attributes.class "is-disabled"
isDangerClass = Attributes.class "is-danger"
helpClass = Attributes.class "help"
isInvisibleClass = Attributes.class "is-invisible"
hasDropDown = Attributes.class "has-dropdown"
isHoverable = Attributes.class "is-hoverable"
navbarLinkClass = Attributes.class "navbar-link"
navbarDropdownClass = Attributes.class "navbar-dropdown"
menuClass = Attributes.class "menu"
menuLabelClass = Attributes.class "menu-label"
columnClass = Attributes.class "column"
isNarrowClass = Attributes.class "is-narrow"
columnsClass = Attributes.class "columns"
menuListClass = Attributes.class "menu-list"
isHalfClass = Attributes.class "is-half"
isOneQuarterClass = Attributes.class "is-one-quarter"
boxClass = Attributes.class "box"
isOneThirdClass = Attributes.class "is-one-third"
is1 = Attributes.class "is-1"
is2 = Attributes.class "is-2"
is3 = Attributes.class "is-3"
is4 = Attributes.class "is-4"
is5 = Attributes.class "is-5"
is6 = Attributes.class "is-6"
iconClass = Attributes.class "icon"
hasTextLinkClass = Attributes.class "has-text-link"
isSize1 = Attributes.class "is-size-1"
isSize7 = Attributes.class "is-size-7"
isSize6 = Attributes.class "is-size-6"
hasTextWeightLight = Attributes.class "has-text-weight-light"
isPulledRightClass = Attributes.class "is-pulled-right"
heroClass = Attributes.class "hero"
isfullHeightClass = Attributes.class "is-full-height"
heroBodyClass = Attributes.class "hero-body"
isPaddingLessClass = Attributes.class "is-padding-less"
heroHeadClass = Attributes.class "hero-head"
heroFootClass = Attributes.class "hero-foot"
modalClass = Attributes.class "modal"
modalBackgroundClass = Attributes.class "modal-background"
modalCardClass = Attributes.class "modal-card"
modalCardHeadClass = Attributes.class "modal-card-head"
modalCardBodyClass = Attributes.class "modal-card-body"
modalCardFootClass = Attributes.class "modal-card-foot"
deleteClass = Attributes.class "delete"
modalCardTitleClass = Attributes.class "modal-card-title"
isSuccessClass = Attributes.class "is-success"
selectClass = Attributes.class "select"
isMultipleClass = Attributes.class "is-multiple"



section : List (Html.Html a) -> Html.Html a
section children =
    Html.div [ sectionClass ]
        [ Html.div [ containerClass ] children ]


labelledField : String -> List (Html.Html a) -> Html.Html a
labelledField label form =
    Html.div [ fieldClass ]
        [ Html.label [ labelClass ]
            [ Html.text label ]
        , Html.div [ controlClass ]
            form
        ]

navbarItem : List (Html.Attribute a) -> String -> String -> Html.Html a
navbarItem attributes path label =
    Html.a ([ navbarItemClass, Attributes.href path ] ++ attributes) [ Html.text label ]

navbarDropdown attributes label items =
    Html.div ([navbarItemClass, hasDropDown] ++ attributes)
        [ Html.span [navbarLinkClass] [Html.text label]
        , Html.div [navbarDropdownClass]
            items
        ]

navbar : Html.Html a -> List (Html.Html a) -> Html.Html a
navbar brand navbarItems =
    Html.nav [ navBarClass, isPrimaryClass ]
        [ brand
        , Html.div [ navbarMenuClass ]
            [ Html.div [ navbarStartClass ] []
            , Html.div [ navbarEndClass ]
                navbarItems
            ]
        ]


field : List (Html.Html a) -> Html.Html a
field form =
    Html.div [ fieldClass ]
        [ Html.div [ controlClass ]
            form
        ]


button : List (Html.Attribute a) -> String -> Html.Html a
button attributes label =
    Html.button ([ buttonClass ] ++ attributes) [ Html.text label ]

file : List (Html.Attribute a) -> List (Html.Attribute a) -> String -> Html.Html a
file attributes fileAttributes label =
    Html.div [ fileClass ]
        [ Html.label ([ fileLabelClass ] ++ attributes)
            [ Html.input ([ fileInputClass, Attributes.type_ "file"] ++ fileAttributes)
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


textInput : List (Html.Attribute a) -> Html.Html a
textInput attributes =
    Html.input ([ inputClass, Attributes.type_ "text" ] ++ attributes) []


passwordInput : List (Html.Attribute a) -> Html.Html a
passwordInput attributes =
    Html.input ([ inputClass, Attributes.type_ "password", Attributes.placeholder "password" ] ++ attributes) []

helpText attributes text =
    Html.p ([ helpClass ] ++ attributes) [ Html.text text ]
