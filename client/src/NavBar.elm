module NavBar exposing (..)
import Model exposing (Model)
import Route
import Bulma

import Html exposing (Attribute, Html, a, text, nav, img, div)
import Html.Attributes exposing (class, href, alt, src, href)


type Msg = Wat

brand path =
    Html.div [ Bulma.navBarBrandClass ]
            [ Html.a [ Bulma.navBarItemClass, href path ]
                [ Html.img [ src "./assets/logo.png", alt "labelspace" ]
                    []
                ]
            ]

navbarItems model routes =
    List.map 
        (\{label, path, route} -> 
            Bulma.navbarItem 
                (if route == model.route 
                then [ Bulma.isActiveClass ] 
                else []
                ) 
                path 
                label
        ) 
        routes

homePageNavbar model =
    Bulma.navbar 
        (brand "/") 
        (navbarItems model 
            [ { label = "pricing", path = Route.pricingRoute, route = Route.Pricing }
            , { label = "register", path = Route.registerRoute, route = Route.Register }
            , { label = "login", path = Route.loginRoute, route = Route.Login }
            ]
        )

appNavbar model =
    Bulma.navbar (brand Route.appRoute) []

navbar : Model -> Html a
navbar model =
    case model.route of
        Route.App -> appNavbar model
        _ -> homePageNavbar model

