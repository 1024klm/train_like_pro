module Router exposing (..)

import Browser.Navigation as Nav
import Types exposing (..)
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, (</>), (<?>), oneOf, s, string, top)
import Url.Parser.Query as Query


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ Parser.map Home top
        , Parser.map Dashboard (s "dashboard")
        , Parser.map (HeroesRoute Nothing) (s "heroes")
        , Parser.map HeroesRoute (s "heroes" <?> heroFilterQuery)
        , Parser.map HeroDetail (s "hero" </> string)
        , Parser.map (Academies Nothing) (s "academies")
        , Parser.map (Academies << Just) (s "academies" </> string)
        , Parser.map AcademyDetail (s "academy" </> string)
        , Parser.map (Events AllEvents) (s "events")
        , Parser.map (Events UpcomingEvents) (s "events" </> s "upcoming")
        , Parser.map (Events PastEvents) (s "events" </> s "past")
        , Parser.map EventDetail (s "event" </> string)
        , Parser.map Training (s "training")
        , Parser.map TrainingView (s "session")
        , Parser.map RoadmapView (s "roadmap" </> string)
        , Parser.map StylePath (s "style" </> string)
        , Parser.map TechniqueLibrary (s "techniques")
        , Parser.map Progress (s "progress")
        , Parser.map Profile (s "profile")
        ]


heroFilterQuery : Query.Parser (Maybe HeroFilter)
heroFilterQuery =
    Query.custom "filter" <|
        \values ->
            case values of
                [ filter ] ->
                    parseHeroFilter filter

                _ ->
                    Nothing


parseHeroFilter : String -> Maybe HeroFilter
parseHeroFilter str =
    case str of
        "all" ->
            Just AllHeroes

        "rooster" ->
            Just (ByWeight Rooster)

        "light-feather" ->
            Just (ByWeight LightFeather)

        "feather" ->
            Just (ByWeight Feather)

        "light" ->
            Just (ByWeight Light)

        "middle" ->
            Just (ByWeight Middle)

        "medium-heavy" ->
            Just (ByWeight MediumHeavy)

        "heavy" ->
            Just (ByWeight Heavy)

        "super-heavy" ->
            Just (ByWeight SuperHeavy)

        "ultra-heavy" ->
            Just (ByWeight UltraHeavy)

        "guard" ->
            Just (ByStyle Guard)

        "passing" ->
            Just (ByStyle Passing)

        "leglocks" ->
            Just (ByStyle LegLocks)

        "wrestling" ->
            Just (ByStyle Wrestling)

        "balanced" ->
            Just (ByStyle Balanced)

        "submission" ->
            Just (ByStyle Submission)

        "pressure" ->
            Just (ByStyle Pressure)

        nationality ->
            if String.startsWith "country-" nationality then
                Just (ByNationality (String.dropLeft 8 nationality))

            else
                Nothing


fromUrl : Url -> Route
fromUrl url =
    Parser.parse routeParser url
        |> Maybe.withDefault NotFound


toPath : Route -> String
toPath route =
    case route of
        Home ->
            "/"

        HeroesRoute maybeFilter ->
            case maybeFilter of
                Nothing ->
                    "/heroes"

                Just filter ->
                    "/heroes" ++ heroFilterToQuery filter

        HeroDetail id ->
            "/hero/" ++ id

        Academies maybeLocation ->
            case maybeLocation of
                Nothing ->
                    "/academies"

                Just location ->
                    "/academies/" ++ location

        AcademyDetail id ->
            "/academy/" ++ id

        Events filter ->
            case filter of
                AllEvents ->
                    "/events"

                UpcomingEvents ->
                    "/events/upcoming"

                PastEvents ->
                    "/events/past"

        EventDetail id ->
            "/event/" ++ id

        Training ->
            "/training"

        TrainingView ->
            "/session"

        Dashboard ->
            "/dashboard"

        RoadmapView id ->
            "/roadmap/" ++ id

        StylePath slug ->
            "/style/" ++ slug

        TechniqueLibrary ->
            "/techniques"

        Progress ->
            "/progress"

        Profile ->
            "/profile"

        NotFound ->
            "/404"


heroFilterToQuery : HeroFilter -> String
heroFilterToQuery filter =
    case filter of
        AllHeroes ->
            "?filter=all"

        ByWeight weight ->
            "?filter=" ++ weightToString weight

        ByNationality country ->
            "?filter=country-" ++ country

        ByStyle style ->
            "?filter=" ++ styleToString style


weightToString : WeightClass -> String
weightToString weight =
    case weight of
        Rooster ->
            "rooster"

        LightFeather ->
            "light-feather"

        Feather ->
            "feather"

        Light ->
            "light"

        Middle ->
            "middle"

        MediumHeavy ->
            "medium-heavy"

        Heavy ->
            "heavy"

        SuperHeavy ->
            "super-heavy"

        UltraHeavy ->
            "ultra-heavy"


styleToString : FightingStyle -> String
styleToString style =
    case style of
        Guard ->
            "guard"

        Passing ->
            "passing"

        LegLocks ->
            "leglocks"

        Wrestling ->
            "wrestling"

        Balanced ->
            "balanced"

        Submission ->
            "submission"

        Pressure ->
            "pressure"


navigateTo : Nav.Key -> Route -> Cmd msg
navigateTo key route =
    Nav.pushUrl key (toPath route)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (toPath route)