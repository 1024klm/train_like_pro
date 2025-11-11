module Pages.Heroes exposing (viewDetail, viewList)

import Dict exposing (Dict)
import Html exposing (Html, button, div, h1, h2, h3, h4, input, label, option, p, select, span, text)
import Html.Attributes exposing (class, classList, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, stopPropagationOn)
import Html.Keyed as Keyed
import String
import I18n
import Json.Decode as Decode
import Set
import Types exposing (..)


viewList : FrontendModel -> Maybe HeroFilter -> Html FrontendMsg
viewList model filter =
    let
        heroesList =
            model.heroes
                |> Dict.values
                |> List.filter (matchesSearch model.searchQuery)
                |> filterHeroes filter
                |> List.sortBy .name
    in
    div [ class "page-stack" ]
        [ div [ class "card page-intro" ]
            [ span [ class "chip chip--outline" ] [ text model.userConfig.t.heroes ]
            , h1 [ class "page-intro__title" ] [ text model.userConfig.t.heroes ]
            , p [ class "page-intro__subtitle" ] [ text model.userConfig.t.learnFromLegends ]
            ]
        , viewHeroFilters model filter
        , Keyed.node "div"
            [ class "grid grid-cols-1 md:grid-cols-3 gap-6" ]
            (heroesList |> List.map (\h -> ( h.id, viewHeroCard model h )))
        ]


viewDetail : FrontendModel -> String -> Html FrontendMsg
viewDetail model heroId =
    let
        t =
            model.userConfig.t
    in
    case Dict.get heroId model.heroes of
        Just hero ->
            div [ class "space-y-6" ]
                [ viewHeroHeader hero model
                , viewHeroContent hero model
                ]

        Nothing ->
            div [ class "p-8 text-center" ]
                [ p [ class "text-gray-400" ] [ text t.heroNotFound ] ]


viewHeroFilters : FrontendModel -> Maybe HeroFilter -> Html FrontendMsg
viewHeroFilters model currentFilter =
    let
        language =
            model.userConfig.language

        t =
            model.userConfig.t

        options =
            heroFilterSelectOptions language t

        selectedValue =
            heroFilterSelectValue currentFilter
    in
    div [ class "filter-row flex items-center gap-3 flex-wrap" ]
        [ label [ class "text-sm font-semibold text-gray-600 dark:text-gray-300" ]
            [ text (filterLabel language) ]
        , input
            [ type_ "text"
            , placeholder (searchPlaceholder language)
            , class "px-4 py-2 rounded-full border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 text-sm font-medium text-gray-700 dark:text-gray-200"
            , value model.searchQuery
            , onInput UpdateSearchQuery
            ]
            []
        , select
            [ class "px-4 py-2 rounded-full border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 text-sm font-medium text-gray-700 dark:text-gray-200"
            , value selectedValue
            , onInput
                (\val ->
                    case heroFilterFromValue val of
                        Nothing ->
                            ApplyFilter AllHeroes

                        Just filter ->
                            ApplyFilter filter
                )
            ]
            (List.map (\( value, label ) -> option [ Html.Attributes.value value ] [ text label ]) options)
        ]


filterLabel : I18n.Language -> String
filterLabel language =
    case language of
        I18n.FR ->
            "Filtrer par"

        I18n.EN ->
            "Filter by"


heroFilterSelectOptions : I18n.Language -> I18n.Translations -> List ( String, String )
heroFilterSelectOptions language t =
    [ ( "all", t.eventsFilterAll )
    , ( "gender-male", genderLabel language Male )
    , ( "gender-female", genderLabel language Female )
    , ( "title-adcc", titleLabel language TitleADCC )
    , ( "title-worlds", titleLabel language TitleWorlds )
    ]


heroFilterSelectValue : Maybe HeroFilter -> String
heroFilterSelectValue maybeFilter =
    case maybeFilter of
        Nothing ->
            "all"

        Just filter ->
            heroFilterValue filter


heroFilterValue : HeroFilter -> String
heroFilterValue filter =
    case filter of
        AllHeroes ->
            "all"

        ByGender Male ->
            "gender-male"

        ByGender Female ->
            "gender-female"

        ByTitle TitleADCC ->
            "title-adcc"

        ByTitle TitleWorlds ->
            "title-worlds"

        _ ->
            "all"


heroFilterFromValue : String -> Maybe HeroFilter
heroFilterFromValue value =
    case value of
        "gender-male" ->
            Just (ByGender Male)

        "gender-female" ->
            Just (ByGender Female)

        "title-adcc" ->
            Just (ByTitle TitleADCC)

        "title-worlds" ->
            Just (ByTitle TitleWorlds)

        _ ->
            Nothing


genderLabel : I18n.Language -> Gender -> String
genderLabel language gender =
    case ( language, gender ) of
        ( I18n.FR, Male ) ->
            "Hommes"

        ( I18n.FR, Female ) ->
            "Femmes"

        ( I18n.EN, Male ) ->
            "Male"

        ( I18n.EN, Female ) ->
            "Female"


titleLabel : I18n.Language -> TitleFilter -> String
titleLabel language titleFilter =
    case ( language, titleFilter ) of
        ( I18n.FR, TitleADCC ) ->
            "Titres ADCC"

        ( I18n.FR, TitleWorlds ) ->
            "Titres mondiaux"

        ( I18n.EN, TitleADCC ) ->
            "ADCC Titles"

        ( I18n.EN, TitleWorlds ) ->
            "World Titles"


searchPlaceholder : I18n.Language -> String
searchPlaceholder language =
    case language of
        I18n.FR ->
            "Rechercher un champion"

        I18n.EN ->
            "Search for a champion"


matchesSearch : String -> Hero -> Bool
matchesSearch query hero =
    let
        trimmed =
            String.trim query

        lowered =
            String.toLower trimmed
    in
    if String.isEmpty trimmed then
        True

    else
        let
            nameMatch =
                String.toLower hero.name |> String.contains lowered

            nicknameMatch =
                String.toLower hero.nickname |> String.contains lowered

            bioMatch =
                String.toLower hero.bio |> String.contains lowered
        in
        nameMatch || nicknameMatch || bioMatch


filterHeroes : Maybe HeroFilter -> List Hero -> List Hero
filterHeroes maybeFilter heroes =
    case maybeFilter of
        Nothing ->
            heroes

        Just AllHeroes ->
            heroes

        Just (ByWeight weight) ->
            List.filter (\h -> h.weight == weight) heroes

        Just (ByStyle style) ->
            List.filter (\h -> h.style == style) heroes

        Just (ByNationality nationality) ->
            List.filter (\h -> h.nationality == nationality) heroes
        
        Just (ByGender gender) ->
            List.filter (\h -> h.gender == gender) heroes
        
        Just (ByTitle titleFilter) ->
            let
                hasTitle containsTitle hero =
                    List.any (\t -> String.toLower t |> String.contains (String.toLower containsTitle)) hero.record.titles
            in
            case titleFilter of
                TitleADCC ->
                    List.filter (hasTitle "adcc") heroes

                TitleWorlds ->
                    List.filter (\h -> hasTitle "world" h || hasTitle "ibjjf" h) heroes


viewHeroCard : FrontendModel -> Hero -> Html FrontendMsg
viewHeroCard model hero =
    let
        isFavorite =
            Set.member hero.id model.favorites.heroes

        recordLabel =
            String.fromInt hero.record.wins ++ " - " ++ String.fromInt hero.record.losses

        weightLabel =
            weightClassToString hero.weight
            
    in
    div
        [ onClick (SelectHero hero.id)
        , class "card list-card list-card--interactive p-6"
        ]
        [ div [ class "flex flex-col items-start md:items-start text-left gap-2" ]
            [ span [ class "chip chip--outline" ] [ text weightLabel ]
            , h3 [ class "list-card__title" ] [ text hero.name ]
            , p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text hero.nickname ]
            , p [ class "list-card__description" ] [ text hero.bio ]
            ]
        , div [ class "list-card__footer flex items-center justify-between gap-4 w-full" ]
            [ span [ class "list-card__meta" ] [ text (hero.nationality ++ " · " ++ recordLabel) ]
            , span [ class "text-primary-500 font-medium" ] [ text "View Details" ]
            , button
                [ onClick (ToggleFavorite HeroFavorite hero.id)
                , stopPropagationOn "click" (Decode.succeed ( NoOpFrontendMsg, True ))
                , classList
                    [ ( "list-card__favorite list-card__favorite--active", isFavorite )
                    , ( "list-card__favorite", not isFavorite )
                    ]
                ]
                [ text (if isFavorite then "★" else "☆") ]
            ]
        ]


weightClassToString : WeightClass -> String
weightClassToString weight =
    case weight of
        Rooster ->
            "Rooster"

        LightFeather ->
            "Light Feather"

        Feather ->
            "Feather"

        Light ->
            "Light"

        Middle ->
            "Middle"

        MediumHeavy ->
            "Medium Heavy"

        Heavy ->
            "Heavy"

        SuperHeavy ->
            "Super Heavy"

        UltraHeavy ->
            "Ultra Heavy"


weightClassLabel : I18n.Language -> WeightClass -> String
weightClassLabel language weight =
    case ( language, weight ) of
        ( I18n.FR, Rooster ) ->
            "Poids coq"

        ( I18n.FR, LightFeather ) ->
            "Plume léger"

        ( I18n.FR, Feather ) ->
            "Plume"

        ( I18n.FR, Light ) ->
            "Léger"

        ( I18n.FR, Middle ) ->
            "Moyen"

        ( I18n.FR, MediumHeavy ) ->
            "Moyen-lourd"

        ( I18n.FR, Heavy ) ->
            "Lourd"

        ( I18n.FR, SuperHeavy ) ->
            "Super-lourd"

        ( I18n.FR, UltraHeavy ) ->
            "Ultra-lourd"

        ( _, Rooster ) ->
            "Rooster"

        ( _, LightFeather ) ->
            "Light Feather"

        ( _, Feather ) ->
            "Feather"

        ( _, Light ) ->
            "Light"

        ( _, Middle ) ->
            "Middle"

        ( _, MediumHeavy ) ->
            "Medium Heavy"

        ( _, Heavy ) ->
            "Heavy"

        ( _, SuperHeavy ) ->
            "Super Heavy"

        ( _, UltraHeavy ) ->
            "Ultra Heavy"


styleLabel : I18n.Language -> FightingStyle -> String
styleLabel language style =
    case ( language, style ) of
        ( I18n.FR, Guard ) ->
            "Garde"

        ( I18n.FR, Passing ) ->
            "Passage"

        ( I18n.FR, LegLocks ) ->
            "Attaques de jambes"

        ( I18n.FR, Wrestling ) ->
            "Lutte"

        ( I18n.FR, Balanced ) ->
            "Équilibré"

        ( I18n.FR, Submission ) ->
            "Soumissions"

        ( I18n.FR, Pressure ) ->
            "Pression"

        ( _, Guard ) ->
            "Guard"

        ( _, Passing ) ->
            "Passing"

        ( _, LegLocks ) ->
            "Leg Locks"

        ( _, Wrestling ) ->
            "Wrestling"

        ( _, Balanced ) ->
            "Balanced"

        ( _, Submission ) ->
            "Submission"

        ( _, Pressure ) ->
            "Pressure"


viewHeroHeader : Hero -> FrontendModel -> Html FrontendMsg
viewHeroHeader hero model =
    let
        t =
            model.userConfig.t

        language =
            model.userConfig.language

        isFavorite =
            Set.member hero.id model.favorites.heroes
    in
    div [ class "relative h-96 bg-gradient-to-br from-red-600 to-red-800" ]
        [ div [ class "absolute inset-0 bg-black/40" ] []
        , div [ class "container mx-auto px-4 h-full flex items-end pb-8" ]
            [ div [ class "text-white" ]
                [ h1 [ class "text-5xl font-bold mb-2" ] [ text hero.name ]
                , p [ class "text-2xl mb-4 opacity-90" ] [ text hero.nickname ]
                , div [ class "flex items-center space-x-4" ]
                    [ span [ class "px-4 py-2 bg-white/20 backdrop-blur rounded-lg" ]
                        [ text hero.team ]
                    , span [ class "px-4 py-2 bg-white/20 backdrop-blur rounded-lg" ]
                        [ text (weightClassLabel language hero.weight) ]
                    , button
                        [ onClick (ToggleFavorite HeroFavorite hero.id)
                        , class "px-4 py-2 bg-white/20 backdrop-blur rounded-lg hover:bg-white/30 transition-colors"
                        ]
                        [ text
                            (if isFavorite then
                                "❤️ " ++ t.favorited

                             else
                                "🤍 " ++ t.addToFavorites
                            )
                        ]
                    ]
                ]
            ]
        ]


viewHeroContent : Hero -> FrontendModel -> Html FrontendMsg
viewHeroContent hero model =
    let
        t =
            model.userConfig.t
    in
    div [ class "space-y-6 lg:space-y-0" ]
        [ div [ class "grid grid-cols-1 lg:grid-cols-3 gap-4 lg:gap-6" ]
            [ div [ class "lg:col-span-2 space-y-8" ]
                [ viewHeroBio t hero
                , viewHeroRecord t hero
                , viewHeroTechniques t hero
                , viewHeroVideos t hero
                ]
            , div [ class "space-y-8" ]
                [ viewHeroStats t hero
                , viewHeroSocial t hero
                , viewHeroAchievements t hero
                ]
            ]
        ]


viewHeroBio : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroBio t hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.biography ]
        , p [ class "text-gray-600 dark:text-gray-300 leading-relaxed" ] [ text hero.bio ]
        ]


viewHeroRecord : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroRecord t hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.competitionRecord ]
        , div [ class "grid grid-cols-3 gap-4 mb-6" ]
            [ recordStat t.wins (String.fromInt hero.record.wins) "text-green-600"
            , recordStat t.losses (String.fromInt hero.record.losses) "text-red-600"
            , recordStat t.draws (String.fromInt hero.record.draws) "text-gray-600"
            ]
        , div [ class "space-y-2" ]
            (List.map
                (\title ->
                    div [ class "flex items-center space-x-2" ]
                        [ span [ class "text-xl" ] [ text "🏆" ]
                        , span [ class "text-gray-700 dark:text-gray-300" ] [ text title ]
                        ]
                )
                hero.record.titles
            )
        ]


recordStat : String -> String -> String -> Html FrontendMsg
recordStat label value colorClass =
    div [ class "text-center" ]
        [ p [ class ("text-3xl font-bold " ++ colorClass) ] [ text value ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text label ]
        ]


viewHeroTechniques : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroTechniques translations hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text translations.signatureTechniques ]
        , Keyed.node "div"
            [ class "space-y-4" ]
            (hero.techniques
                |> List.sortBy .name
                |> List.map (\techniqueInfo -> ( techniqueInfo.id, viewTechnique techniqueInfo ))
            )
        ]


viewTechnique : Technique -> Html FrontendMsg
viewTechnique technique =
    div [ class "border-l-4 border-red-500 pl-4" ]
        [ h3 [ class "font-bold dark:text-white" ] [ text technique.name ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text technique.description ]
        ]


viewHeroVideos : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroVideos t hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.videos ]
        , Keyed.node "div"
            [ class "grid grid-cols-1 md:grid-cols-2 gap-4" ]
            (hero.videos |> List.sortBy .date |> List.map (\v -> ( v.id, viewVideoCard v )))
        ]


viewVideoCard : Video -> Html FrontendMsg
viewVideoCard video =
    div [ class "bg-gray-700/50 backdrop-blur-sm rounded-lg p-4 hover:shadow-md transition-all cursor-pointer border border-gray-600/30 hover:border-blue-500/50" ]
        [ h3 [ class "font-medium dark:text-white mb-2" ] [ text video.title ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text video.date ]
        ]


viewHeroStats : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroStats t hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.statistics ]
        , div [ class "space-y-3" ]
            [ statRow t.winRate (String.fromFloat hero.stats.winRate ++ "%")
            , statRow t.submissionRate (String.fromFloat hero.stats.submissionRate ++ "%")
            , statRow t.avgMatchTime (String.fromFloat hero.stats.averageMatchTime ++ " min")
            , statRow t.favoritePosition hero.stats.favoritePosition
            , statRow t.favoriteSubmission hero.stats.favoriteSubmission
            ]
        ]


statRow : String -> String -> Html FrontendMsg
statRow label value =
    div [ class "flex justify-between" ]
        [ span [ class "text-gray-600 dark:text-gray-400" ] [ text label ]
        , span [ class "font-medium dark:text-white" ] [ text value ]
        ]


viewHeroSocial : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroSocial t hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.socialMedia ]
        , div [ class "space-y-3" ]
            [ case hero.socialMedia.instagram of
                Just handle ->
                    socialLink "Instagram" handle "📷"

                Nothing ->
                    text ""
            , case hero.socialMedia.youtube of
                Just channel ->
                    socialLink "YouTube" channel "📺"

                Nothing ->
                    text ""
            , case hero.socialMedia.website of
                Just url ->
                    socialLink t.website url "🌐"

                Nothing ->
                    text ""
            ]
        ]


socialLink : String -> String -> String -> Html FrontendMsg
socialLink platform handle icon =
    div [ class "flex items-center space-x-3 hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded-lg cursor-pointer" ]
        [ span [ class "text-xl" ] [ text icon ]
        , div [ class "flex-1" ]
            [ p [ class "font-medium dark:text-white" ] [ text platform ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text handle ]
            ]
        ]


viewHeroAchievements : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroAchievements t hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.achievements ]
        , if List.isEmpty hero.achievements then
            p [ class "text-gray-500 dark:text-gray-400" ] [ text t.noAchievementsYet ]

          else
            div [ class "space-y-3" ]
                (List.map viewAchievement hero.achievements)
        ]


viewAchievement : Achievement -> Html FrontendMsg
viewAchievement achievement =
    div [ class "flex items-center space-x-3" ]
        [ span [ class "text-2xl" ] [ text achievement.icon ]
        , div [ class "flex-1" ]
            [ p [ class "font-medium dark:text-white" ] [ text achievement.name ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text achievement.description ]
            ]
        ]
