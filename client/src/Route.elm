module Route exposing (..)


import Url.Parser exposing (Parser, (</>), int, map, oneOf, s, string, parse, top)
import Url.Parser.Query as Query
import Url


pricingRoute = "/pricing"
registerRoute = "/register"
confirmRout = "/route"
loginRoute = "/login"
confirmRoute username = "/confirm" ++ "/" ++ username
root = "/"


type Route
    = Home
    | Pricing
    | Register
    | Confirm String
    | Login
    | NotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map Pricing (s "pricing")
        , map Register (s "register")
        , map Login (s "login")
        , map Confirm (s "confirm" </> string)
        ]


toRoute : Url.Url -> Route
toRoute url =
        Maybe.withDefault NotFound (parse route url)