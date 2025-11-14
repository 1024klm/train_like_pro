module Pages.Heroes exposing (viewDetail, viewList)

import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h1, h2, h3, h4, img, input, label, li, option, p, select, span, text, ul)
import Html.Attributes exposing (alt, class, classList, href, placeholder, rel, src, style, target, type_, value)
import Html.Events exposing (onClick, onInput, stopPropagationOn)
import Html.Keyed as Keyed
import I18n
import Json.Decode as Decode
import Set
import String
import Types exposing (..)


viewList : FrontendModel -> Maybe HeroFilter -> Html FrontendMsg
viewList model filter =
    let
        favoriteHeroes =
            model.favorites.heroes
                |> Set.toList
                |> List.filterMap (\heroId -> Dict.get heroId model.heroes)
                |> List.sortBy .name

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
        , viewFavoriteHeroes model favoriteHeroes
        , viewHeroFilters model filter
        , Keyed.node "div"
            [ class "grid grid-cols-1 md:grid-cols-3 gap-6" ]
            (heroesList |> List.map (\h -> ( h.id, viewHeroCard model h )))
        ]


viewFavoriteHeroes : FrontendModel -> List Hero -> Html FrontendMsg
viewFavoriteHeroes model favorites =
    if List.isEmpty favorites then
        text ""

    else
        let
            t =
                model.userConfig.t
        in
        div [ class "card space-y-5" ]
            [ div [ class "flex items-center justify-between gap-3" ]
                [ div []
                    [ span [ class "chip chip--outline" ] [ text t.favorites ]
                    , h2 [ class "text-2xl font-bold mt-2 text-gray-900 dark:text-white" ] [ text t.favorites ]
                    ]
                , if List.length favorites > 3 then
                    span [ class "text-sm font-medium text-gray-500 dark:text-gray-400" ]
                        [ text (String.fromInt (List.length favorites) ++ " / " ++ String.fromInt (Dict.size model.heroes)) ]

                  else
                    text ""
                ]
            , div [ class "flex gap-4 overflow-x-auto pb-2" ]
                (favorites |> List.map (viewFavoriteHeroCard model))
            ]


viewDetail : FrontendModel -> String -> Html FrontendMsg
viewDetail model heroId =
    let
        t =
            model.userConfig.t
    in
    case Dict.get heroId model.heroes of
        Just hero ->
            div [ class "space-y-10 pb-16" ]
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

        language =
            model.userConfig.language

        t =
            model.userConfig.t

        recordLabel =
            heroRecordLabel language hero.record

        weightLabel =
            weightClassToString hero.weight

        taglineView =
            case heroTagline hero of
                Just line ->
                    [ p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text line ] ]

                Nothing ->
                    []

        chipsView =
            let
                chips =
                    heroMetaChips hero
            in
            if List.isEmpty chips then
                []

            else
                [ div [ class "flex flex-wrap gap-2 text-xs text-gray-600 dark:text-gray-300" ]
                    (List.map heroMetaChip chips)
                ]
    in
    div
        [ onClick (SelectHero hero.id)
        , class "card list-card list-card--interactive p-6"
        ]
        [ div [ class "flex flex-col items-start md:items-start text-left gap-2" ]
            ([ span [ class "chip chip--outline" ] [ text weightLabel ]
             , h3 [ class "list-card__title" ] [ text hero.name ]
             ]
                ++ taglineView
                ++ chipsView
                ++ [ p [ class "list-card__description" ] [ text hero.bio ] ]
            )
        , div [ class "list-card__footer flex items-center justify-between gap-4 w-full" ]
            [ span [ class "list-card__meta" ] [ text (hero.nationality ++ " · " ++ recordLabel) ]
            , span [ class "text-primary-500 font-medium" ] [ text t.viewDetails ]
            , button
                [ stopPropagationOn "click" (Decode.succeed ( ToggleFavorite HeroFavorite hero.id, True ))
                , classList
                    [ ( "list-card__favorite list-card__favorite--active", isFavorite )
                    , ( "list-card__favorite", not isFavorite )
                    ]
                ]
                [ text
                    (if isFavorite then
                        "★"

                     else
                        "☆"
                    )
                ]
            ]
        ]


viewFavoriteHeroCard : FrontendModel -> Hero -> Html FrontendMsg
viewFavoriteHeroCard model hero =
    let
        language =
            model.userConfig.language

        recordLabel =
            heroRecordLabel language hero.record

        isFavorite =
            Set.member hero.id model.favorites.heroes
    in
    div
        [ onClick (SelectHero hero.id)
        , class "group flex min-w-[260px] flex-1 items-center gap-4 rounded-2xl border border-purple-100 bg-white/90 p-4 shadow-md transition hover:-translate-y-1 hover:shadow-purple-lg dark:border-purple-900/40 dark:bg-gray-900/80"
        ]
        [ img
            [ src hero.imageUrl
            , alt hero.name
            , class "h-16 w-16 rounded-2xl object-cover ring-2 ring-purple-100 transition group-hover:ring-purple-400 dark:ring-purple-900/60"
            ]
            []
        , div [ class "flex-1 space-y-1" ]
            [ h3 [ class "text-base font-semibold text-gray-900 dark:text-white" ] [ text hero.name ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text (hero.nationality ++ " · " ++ recordLabel) ]
            , case heroTagline hero of
                Just line ->
                    p [ class "text-sm text-purple-600 dark:text-purple-300" ] [ text line ]

                Nothing ->
                    text ""
            ]
        , button
            [ stopPropagationOn "click" (Decode.succeed ( ToggleFavorite HeroFavorite hero.id, True ))
            , classList
                [ ( "list-card__favorite list-card__favorite--active", isFavorite )
                , ( "list-card__favorite", not isFavorite )
                ]
            ]
            [ text
                (if isFavorite then
                    "★"

                 else
                    "☆"
                )
            ]
        ]


heroTagline : Hero -> Maybe String
heroTagline hero =
    let
        parts =
            [ nonEmpty hero.nickname, nonEmpty hero.team ]
                |> List.filterMap identity
    in
    case parts of
        [] ->
            Nothing

        _ ->
            Just (String.join " · " parts)


heroMetaChips : Hero -> List String
heroMetaChips hero =
    [ nonEmpty hero.stats.favoritePosition
    , nonEmpty hero.stats.favoriteSubmission
    , hero.record.titles |> List.head |> Maybe.map String.trim |> Maybe.andThen nonEmpty
    ]
        |> List.filterMap identity


heroMetaChip : String -> Html msg
heroMetaChip label =
    span
        [ class "inline-flex items-center px-3 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-xs font-medium text-gray-700 dark:text-gray-200" ]
        [ text label ]


heroRecordLabel : I18n.Language -> CompetitionRecord -> String
heroRecordLabel language record =
    if record.wins == 0 && record.losses == 0 && record.draws == 0 then
        case language of
            I18n.FR ->
                "Record : non unifié"

            I18n.EN ->
                "Record: not tracked"

    else
        String.fromInt record.wins ++ " - " ++ String.fromInt record.losses


nonEmpty : String -> Maybe String
nonEmpty str =
    let
        trimmed =
            String.trim str
    in
    if trimmed == "" then
        Nothing

    else
        Just trimmed


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

        headerStats =
            [ heroHeaderStat t.winRate (String.fromFloat hero.stats.winRate ++ "%")
            , heroHeaderStat t.submissionRate (String.fromFloat hero.stats.submissionRate ++ "%")
            , heroHeaderStat t.achievements (String.fromInt (List.length hero.record.titles))
            ]
    in
    div
        [ class "relative overflow-hidden rounded-3xl border border-purple-100/60 bg-gray-900 text-white shadow-purple-xl dark:border-purple-900/50"
        , class "transition-all duration-300"
        ]
        [ div
            [ class "absolute inset-0 opacity-70"
            , style "background-image" ("linear-gradient(135deg, rgba(30,27,75,0.8), rgba(67,56,202,0.85)), url(" ++ hero.coverImageUrl ++ ")")
            , style "background-size" "cover"
            , style "background-position" "center"
            ]
            []
        , div [ class "absolute inset-0 bg-black/30" ] []
        , div [ class "relative grid gap-10 p-6 md:p-10 lg:grid-cols-[240px,1fr]" ]
            [ div [ class "flex flex-col items-center gap-6 text-center lg:items-start lg:text-left" ]
                [ img
                    [ src hero.imageUrl
                    , alt hero.name
                    , class "h-48 w-48 rounded-3xl border-4 border-white/50 object-cover shadow-2xl ring-4 ring-white/10"
                    ]
                    []
                , div [ class "flex flex-wrap justify-center gap-2 lg:justify-start" ]
                    (heroHeaderBadges language hero)
                ]
            , div [ class "space-y-6" ]
                [ div [ class "space-y-2" ]
                    [ span [ class "text-xs font-semibold uppercase tracking-[0.4em] text-white/70" ] [ text t.trainLikeChampion ]
                    , h1 [ class "text-4xl font-bold tracking-tight md:text-5xl" ] [ text hero.name ]
                    , if String.isEmpty hero.nickname then
                        text ""

                      else
                        p [ class "text-xl text-white/80" ] [ text ("“" ++ hero.nickname ++ "”") ]
                    , p [ class "text-base text-white/80" ] [ text hero.bio ]
                    ]
                , div [ class "grid gap-4 md:grid-cols-3" ] headerStats
                , heroHeaderActions hero model isFavorite
                ]
            ]
        ]


heroHeaderStat : String -> String -> Html FrontendMsg
heroHeaderStat label value =
    div [ class "rounded-2xl border border-white/20 bg-white/10 px-4 py-4 text-center backdrop-blur shadow-lg" ]
        [ p [ class "text-xs font-semibold uppercase tracking-[0.35em] text-white/60" ] [ text label ]
        , p [ class "mt-2 text-2xl font-semibold" ] [ text value ]
        ]


heroHeaderBadges : I18n.Language -> Hero -> List (Html FrontendMsg)
heroHeaderBadges language hero =
    [ ( "🌍", hero.nationality )
    , ( "🏛", hero.team )
    , ( "⚖️", weightClassLabel language hero.weight )
    , ( "🎯", styleLabel language hero.style )
    ]
        |> List.filter (\( _, value ) -> not (String.isEmpty value))
        |> List.map
            (\( icon, value ) ->
                span
                    [ class "inline-flex items-center gap-2 rounded-full border border-white/30 bg-white/10 px-3 py-1 text-sm font-medium text-white/90 backdrop-blur" ]
                    [ span [ class "text-lg" ] [ text icon ]
                    , span [] [ text value ]
                    ]
            )


heroHeaderActions : Hero -> FrontendModel -> Bool -> Html FrontendMsg
heroHeaderActions hero model isFavorite =
    let
        t =
            model.userConfig.t

        ( selectLabel, selectIcon, selectClasses ) =
            if isFavorite then
                ( t.championSelected
                , "✓"
                , "inline-flex items-center gap-2 rounded-full bg-purple-600 px-5 py-2 text-sm font-semibold text-white shadow-lg transition hover:-translate-y-0.5 hover:shadow-xl"
                )

            else
                ( t.selectChampion
                , "＋"
                , "inline-flex items-center gap-2 rounded-full bg-white px-5 py-2 text-sm font-semibold text-purple-700 shadow-lg transition hover:-translate-y-0.5 hover:shadow-xl"
                )
    in
    div [ class "flex flex-wrap gap-3" ]
        [ button
            [ onClick (ToggleFavorite HeroFavorite hero.id)
            , class selectClasses
            ]
            [ span [ class "text-base" ] [ text selectIcon ]
            , span [] [ text selectLabel ]
            ]
        , button
            [ onClick (NavigateTo (HeroesRoute Nothing))
            , class "inline-flex items-center gap-2 rounded-full border border-white/30 bg-white/10 px-5 py-2 text-sm font-semibold text-white transition hover:bg-white/20"
            ]
            [ text ("← " ++ t.heroes) ]
        ]


viewHeroContent : Hero -> FrontendModel -> Html FrontendMsg
viewHeroContent hero model =
    let
        t =
            model.userConfig.t

        language =
            model.userConfig.language
    in
    div [ class "space-y-8" ]
        [ div [ class "grid gap-6 lg:grid-cols-[2fr,1fr]" ]
            [ div [ class "space-y-6" ]
                [ viewHeroBio t language hero
                , viewHeroRecord t hero
                , viewHeroTechniques t hero
                ]
            , div [ class "space-y-6" ]
                [ viewHeroStats t hero
                , viewHeroSocial t hero
                , viewHeroAchievements t hero
                ]
            ]
        ]


viewHeroBio : I18n.Translations -> I18n.Language -> Hero -> Html FrontendMsg
viewHeroBio t language hero =
    let
        meta =
            [ ( "🌍", hero.nationality )
            , ( "🏛️", hero.team )
            , ( "⚖️", weightClassLabel language hero.weight )
            , ( "🎯", styleLabel language hero.style )
            ]
                |> List.filter (\( _, value ) -> not (String.isEmpty value))
    in
    div [ class "rounded-2xl border border-gray-200/80 bg-white/95 p-6 shadow-xl shadow-purple-100/40 dark:border-gray-800 dark:bg-gray-900/70 dark:shadow-purple-900/30" ]
        [ h2 [ class "text-2xl font-bold text-gray-900 dark:text-white" ] [ text t.biography ]
        , p [ class "mt-3 text-gray-600 dark:text-gray-300 leading-relaxed" ] [ text hero.bio ]
        , if List.isEmpty meta then
            text ""

          else
            div [ class "mt-6 grid gap-3 sm:grid-cols-2" ]
                (List.map heroMetaRow meta)
        ]


heroMetaRow : ( String, String ) -> Html FrontendMsg
heroMetaRow ( icon, value ) =
    div [ class "flex items-center gap-3 rounded-xl border border-gray-100/80 bg-white/60 px-3 py-2 text-sm font-semibold text-gray-700 shadow-inner dark:border-gray-800 dark:bg-gray-900/60 dark:text-gray-200" ]
        [ span [ class "text-xl" ] [ text icon ]
        , span [] [ text value ]
        ]


viewHeroRecord : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroRecord t hero =
    div [ class "rounded-2xl border border-gray-200/80 bg-white/95 p-6 shadow-xl dark:border-gray-800 dark:bg-gray-900/70" ]
        [ div [ class "flex flex-col gap-2" ]
            [ h2 [ class "text-2xl font-bold text-gray-900 dark:text-white" ] [ text t.competitionRecord ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ]
                [ text (hero.name ++ " · " ++ String.fromInt hero.record.wins ++ "-" ++ String.fromInt hero.record.losses ++ "-" ++ String.fromInt hero.record.draws) ]
            ]
        , div [ class "mt-6 grid gap-4 md:grid-cols-3" ]
            [ recordStat t.wins (String.fromInt hero.record.wins) "text-green-600"
            , recordStat t.losses (String.fromInt hero.record.losses) "text-red-600"
            , recordStat t.draws (String.fromInt hero.record.draws) "text-gray-600"
            ]
        , if List.isEmpty hero.record.titles then
            text ""

          else
            div [ class "mt-6 space-y-3" ]
                [ h3 [ class "text-sm font-semibold uppercase tracking-[0.4em] text-gray-500 dark:text-gray-400" ] [ text t.achievements ]
                , div [ class "flex flex-wrap gap-2" ]
                    (List.map viewTitleChip hero.record.titles)
                ]
        ]


viewTitleChip : String -> Html FrontendMsg
viewTitleChip title =
    span [ class "inline-flex items-center gap-2 rounded-full border border-purple-200/70 bg-purple-50/70 px-3 py-1 text-xs font-semibold text-purple-800 shadow-sm dark:border-purple-900/50 dark:bg-purple-900/30 dark:text-purple-200" ]
        [ span [ class "text-sm" ] [ text "🏆" ]
        , span [] [ text title ]
        ]


recordStat : String -> String -> String -> Html FrontendMsg
recordStat label value colorClass =
    div [ class "rounded-2xl border border-gray-100/80 bg-white/70 px-4 py-5 text-center shadow-inner dark:border-gray-800 dark:bg-gray-900/60" ]
        [ p [ class ("text-3xl font-bold " ++ colorClass) ] [ text value ]
        , p [ class "mt-1 text-sm text-gray-500 dark:text-gray-400" ] [ text label ]
        ]


viewHeroTechniques : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroTechniques translations hero =
    div [ class "rounded-2xl border border-gray-200/80 bg-white/95 p-6 shadow-xl dark:border-gray-800 dark:bg-gray-900/70" ]
        [ h2 [ class "text-2xl font-bold text-gray-900 dark:text-white" ] [ text translations.signatureTechniques ]
        , Keyed.node "div"
            [ class "space-y-4" ]
            (hero.techniques
                |> List.sortBy .name
                |> List.map (\techniqueInfo -> ( techniqueInfo.id, viewTechnique techniqueInfo ))
            )
        ]


viewTechnique : Technique -> Html FrontendMsg
viewTechnique technique =
    let
        detailItems =
            technique.keyDetails
                |> List.map
                    (\detail ->
                        li [ class "flex items-baseline gap-2 text-gray-600 dark:text-gray-300" ]
                            [ span [ class "text-purple-500" ] [ text "•" ]
                            , span [] [ text detail ]
                            ]
                    )
    in
    div [ class "rounded-2xl border border-gray-100/80 bg-white/80 p-5 shadow-inner transition hover:-translate-y-0.5 hover:border-purple-200 dark:border-gray-800 dark:bg-gray-900/60" ]
        [ div [ class "flex items-center justify-between gap-4" ]
            [ h3 [ class "text-lg font-semibold text-gray-900 dark:text-white" ] [ text technique.name ]
            , span [ class "text-xs font-semibold uppercase tracking-[0.3em] text-purple-600 dark:text-purple-300" ]
                [ text ("+" ++ String.fromInt technique.xpValue ++ " XP") ]
            ]
        , p [ class "mt-2 text-sm text-gray-600 dark:text-gray-300" ] [ text technique.description ]
        , if List.isEmpty technique.keyDetails then
            text ""

          else
            ul [ class "mt-3 space-y-1 text-sm" ] detailItems
        ]


viewHeroStats : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroStats t hero =
    div [ class "rounded-2xl border border-gray-200/80 bg-white/95 p-6 shadow-xl dark:border-gray-800 dark:bg-gray-900/70" ]
        [ h2 [ class "text-2xl font-bold text-gray-900 dark:text-white" ] [ text t.statistics ]
        , div [ class "mt-4 space-y-3" ]
            [ statRow t.winRate (String.fromFloat hero.stats.winRate ++ "%")
            , statRow t.submissionRate (String.fromFloat hero.stats.submissionRate ++ "%")
            , statRow t.avgMatchTime (String.fromFloat hero.stats.averageMatchTime ++ " min")
            , statRow t.favoritePosition hero.stats.favoritePosition
            , statRow t.favoriteSubmission hero.stats.favoriteSubmission
            ]
        ]


statRow : String -> String -> Html FrontendMsg
statRow label value =
    div [ class "flex items-center justify-between rounded-xl border border-gray-100/80 bg-white/60 px-4 py-3 text-sm shadow-inner dark:border-gray-800 dark:bg-gray-900/60" ]
        [ span [ class "text-gray-600 dark:text-gray-400" ] [ text label ]
        , span [ class "font-semibold text-gray-900 dark:text-white" ] [ text value ]
        ]


viewHeroSocial : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroSocial t hero =
    let
        instagramView =
            case hero.socialMedia.instagram of
                Just handle ->
                    [ socialLink "Instagram" handle "📷" ]

                Nothing ->
                    []

        youtubeView =
            case hero.socialMedia.youtube of
                Just channel ->
                    [ socialLink "YouTube" channel "📺" ]

                Nothing ->
                    []

        websiteView =
            case hero.socialMedia.website of
                Just url ->
                    [ socialLink t.website url "🌐" ]

                Nothing ->
                    []

        socialItems =
            instagramView ++ youtubeView ++ websiteView
    in
    div [ class "rounded-2xl border border-gray-200/80 bg-white/95 p-6 shadow-xl dark:border-gray-800 dark:bg-gray-900/70" ]
        [ h2 [ class "text-2xl font-bold text-gray-900 dark:text-white" ] [ text t.socialMedia ]
        , if List.isEmpty socialItems then
            text ""

          else
            div [ class "mt-4 space-y-3" ] socialItems
        ]


socialLink : String -> String -> String -> Html FrontendMsg
socialLink platform handle icon =
    div [ class "flex items-center gap-3 rounded-2xl border border-gray-100/80 bg-white/70 px-4 py-3 text-sm shadow-inner transition hover:-translate-y-0.5 hover:border-purple-200 dark:border-gray-800 dark:bg-gray-900/60" ]
        [ span [ class "text-2xl" ] [ text icon ]
        , div [ class "flex-1" ]
            [ p [ class "font-semibold text-gray-900 dark:text-white" ] [ text platform ]
            , p [ class "text-gray-500 dark:text-gray-400" ] [ text handle ]
            ]
        ]


viewHeroAchievements : I18n.Translations -> Hero -> Html FrontendMsg
viewHeroAchievements t hero =
    div [ class "rounded-2xl border border-gray-200/80 bg-white/95 p-6 shadow-xl dark:border-gray-800 dark:bg-gray-900/70" ]
        [ h2 [ class "text-2xl font-bold text-gray-900 dark:text-white" ] [ text t.achievements ]
        , if List.isEmpty hero.achievements then
            p [ class "text-gray-500 dark:text-gray-400" ] [ text t.noAchievementsYet ]

          else
            div [ class "mt-4 space-y-3" ]
                (List.map viewAchievement hero.achievements)
        ]


viewAchievement : Achievement -> Html FrontendMsg
viewAchievement achievement =
    div [ class "flex items-center gap-3 rounded-2xl border border-gray-100/80 bg-white/70 px-4 py-3 shadow-inner dark:border-gray-800 dark:bg-gray-900/60" ]
        [ span [ class "text-2xl" ] [ text achievement.icon ]
        , div [ class "flex-1" ]
            [ p [ class "font-semibold text-gray-900 dark:text-white" ] [ text achievement.name ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text achievement.description ]
            ]
        ]
