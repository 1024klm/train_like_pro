module Router.Helpers exposing (onPreventDefaultClick, isInternalHref, isInternalHrefWithUrl)

import Html exposing (Attribute)
import Html.Events as E
import Json.Decode as D
import Url exposing (Url)

onPreventDefaultClick : msg -> Attribute msg
onPreventDefaultClick msg =
    E.preventDefaultOn "click" (D.succeed ( msg, True ))

isInternalHref : String -> Bool
isInternalHref href =
    String.startsWith "/" href || String.startsWith "#" href

isInternalHrefWithUrl : Url -> String -> Bool
isInternalHrefWithUrl currentUrl href =
    -- Check for relative paths and anchors first
    if String.startsWith "/" href || String.startsWith "#" href then
        True
    else
        -- Check if it's a same-origin absolute URL
        case Url.fromString href of
            Nothing ->
                False  -- Invalid URL

            Just targetUrl ->
                -- Same-origin if protocol, host, and port match
                currentUrl.protocol == targetUrl.protocol &&
                currentUrl.host == targetUrl.host &&
                currentUrl.port_ == targetUrl.port_