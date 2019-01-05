module Route exposing (Route(..), RouteMap, appRoute, confirmRoute, loginRoute, pricingRoute, registerRoute, route, toRoute)

import Dict exposing (Dict)
import Url
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query


type alias RouteMap =
    ( String, Route )


type Route
    = Home
    | Pricing
    | Register
    | Confirm (Maybe String)
    | Login
    | NotFound
    | App


pricingRoute =
    "/pricing"


registerRoute =
    "/register"


loginRoute =
    "/login"


confirmRoute email =
    Builder.absolute [ "confirm" ] [ Builder.string "email" email ]


appRoute =
    "/app"


route : Parser.Parser (Route -> a) a
route =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Pricing (Parser.s "pricing")
        , Parser.map Register (Parser.s "register")
        , Parser.map Login (Parser.s "login")
        , Parser.map Confirm (Parser.s "confirm" <?> Query.string "email")
        , Parser.map App (Parser.s "app")
        ]


toRoute : Url.Url -> Route
toRoute url =
    Maybe.withDefault NotFound (Parser.parse route url)
