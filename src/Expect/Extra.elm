module Expect.Extra exposing
    ( match, MatchPattern, stringPattern, regexPattern
    , contain, member
    )

{-| Extends `Expect` with more `Expectation`s.


## Strings

@docs match, MatchPattern, stringPattern, regexPattern


## Lists

@docs contain, member

-}

import Expect exposing (..)
import Regex


{-| An expectation represented as a pattern to match a string.
-}
type MatchPattern
    = StringPattern String
    | RegexPattern String


{-| Matches if the pattern is contained within the actual string value.
-}
stringPattern : String -> MatchPattern
stringPattern =
    StringPattern


{-| Matches if the regular expression matches the actual string value.
-}
regexPattern : String -> MatchPattern
regexPattern =
    RegexPattern


{-| Passes if the given pattern matches the actual string.

    -- Match with regular expressions
    match (regexPattern "^[0-9a-f]+$") "deadbeef"

    -- Or just plain strings
    match (stringPattern "foo") "foo bar"

-}
match : MatchPattern -> String -> Expectation
match expected actual =
    case expected of
        StringPattern pattern ->
            Expect.true ("\"" ++ actual ++ "\" to contain sub-string: " ++ pattern) <|
                String.contains pattern actual

        RegexPattern pattern ->
            case Regex.fromString pattern of
                Just regex ->
                    Expect.true ("\"" ++ actual ++ "\" to match regex: " ++ pattern) <|
                        Regex.contains regex actual

                Nothing ->
                    Expect.fail <| "Bad pattern given to Expect.Extra.match: " ++ pattern


{-| Passes if value is a member of list.

    member 1 [0, 1, 2]

    -- Passes because 1 is a member of [0, 1, 2]

-}
member : (a -> String) -> a -> List a -> Expectation
member toString value list =
    if List.member value list then
        pass

    else
        fail
            ("Expected:\n  "
                ++ "["
                ++ (List.map toString list |> String.join ", ")
                ++ "]\nto contain:\n  "
                ++ toString value
            )


{-| Alias of `member`.

Reads better with bdd style tests.

    expect [0, 1, 2] to contain 1

    -- Passes because [0, 1, 2] contains 1

-}
contain : a -> (a -> String) -> List a -> Expectation
contain value toString =
    member toString value
