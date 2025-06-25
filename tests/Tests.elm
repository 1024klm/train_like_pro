module Tests exposing (all)

import Test exposing (Test, test)
import Expect


all : Test
all =
    Test.describe "BJJ Heroes App Tests"
        [ test "Basic test - app should exist" <|
            \() ->
                Expect.pass
        ]