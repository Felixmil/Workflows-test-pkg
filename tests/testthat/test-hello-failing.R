# NOTE: This file contains an intentionally failing test, used to demonstrate
# what a failing test looks like in the test suite / CI.

test_that("hello() returns 'goodbye' (intentionally wrong expectation)", {
  # hello() actually returns "hello, brilliant world! (dev contribution)",
  # so this expectation is deliberately incorrect and will FAIL.
  expect_equal(hello(), "goodbye, cruel world!")
})

test_that("hello() returns a numeric value (intentionally wrong expectation)", {
  # hello() returns a character string, not a number, so this will FAIL.
  expect_type(hello(), "double")
})
