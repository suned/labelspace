module NavBar exposing (..)
import Model exposing (Model)
import Route
import Bulma

import Html.Styled exposing (Attribute, Html, a, text, nav, img, div)
import Html.Styled.Attributes exposing (class, href, alt, src, href, style)



type alias RouteConfig =
  { label: String
  , path : String
  , route: Route.Route
  }
brand : String -> Html a
brand path =
    div [ Bulma.navBarBrandClass ]
            [ a [ Bulma.navbarItemClass, href path ]
                [ img [ src "/assets/logo.png", alt "labelspace" ]
                    []
                ]
            ]

navbarItems : Model -> List RouteConfig-> List (Html a)
navbarItems model routes =
    List.map
        (\{label, path, route} ->
            Bulma.navbarItem
                ( if route == model.route
                  then [ Bulma.isActiveClass ]
                  else [] )
                path
                label
        )
        routes

homePageNavbar : Model -> Html a
homePageNavbar model =
    Bulma.navbar
        (brand "/")
        (navbarItems model
            [ { label = "pricing", path = Route.pricingRoute, route = Route.Pricing }
            , { label = "register", path = Route.registerRoute, route = Route.Register }
            , { label = "login", path = Route.loginRoute, route = Route.Login }
            ]
        )

appNavbar : Model -> Html a
appNavbar model =
    Bulma.navbar (brand Route.appRoute)
        [ Bulma.navbarItem [] "" "sign out" ]

navbar : Model -> Html a
navbar model =
    case model.route of
        Route.App -> appNavbar model
        _ -> homePageNavbar model
