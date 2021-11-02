module Tests.Exts.Validation exposing (tests)

import Expect exposing (..)
import Exts.Result exposing (..)
import Exts.Validation exposing (..)
import Regex exposing (..)
import Test exposing (..)


tests : Test
tests =
    describe "Exts.Validation"
        [ emailTests
        , fullFormTests
        ]


emailTests : Test
emailTests =
    describe "email"
        [ test "is valid 1" <|
            always <|
                assertEmail "asdf@asdf.com"
        , test "is valid 2" <|
            always <|
                assertEmail "test-user@test.co.uk"
        , test "is invalid 1" <|
            always <|
                assertNotEmail "THINGS"
        , test "is invalid 2" <|
            always <|
                assertNotEmail "  !\test-user@test.co.uk 01"
        ]


assertEmail : String -> Expectation
assertEmail str =
    true "" (isOk (email "Not an email." (Just str)))


assertNotEmail : String -> Expectation
assertNotEmail str =
    true "" (isErr (email "Not an email." (Just str)))


type alias Form =
    { message : Maybe String
    , email : Maybe String
    , firstName : Maybe String
    , age : Maybe Int
    }


type alias ValidForm =
    { message : String
    , email : String
    , firstName : String
    , age : Int
    }


validateForm : Form -> Result String ValidForm
validateForm form =
    let
        emailRegex =
            "^[a-z]+$"
                |> Regex.fromStringWith { caseInsensitive = True, multiline = False }
                |> Maybe.withDefault Regex.never
    in
    Ok ValidForm
        |> apply (notBlank "Message is required and may not be blank." form.message)
        |> apply (email "Email is required and may not be blank." form.email)
        |> apply (matches emailRegex "First name may only contain letters." form.firstName)
        |> apply (required "Age is required" form.age)


fullFormTests : Test
fullFormTests =
    describe "full form" <|
        List.map (test "is valid" << always)
            [ equal (Err "Age is required")
                (validateForm
                    { message = Just "Hello"
                    , email = Just "test@asdf.com"
                    , firstName = Just "Kris"
                    , age = Nothing
                    }
                )
            ]
