module Router.Helpers exposing (onPreventDefaultClick, isInternalHref)

import Html exposing (Attribute)
import Html.Events as E
import Json.Decode as D

onPreventDefaultClick : msg -> Attribute msg
onPreventDefaultClick msg =
    E.preventDefaultOn "click" (D.succeed ( msg, True ))

isInternalHref : String -> Bool
isInternalHref href =
    String.startsWith "/" href || String.startsWith "#" href