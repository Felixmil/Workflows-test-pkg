test_that("hello() returns a character string", {
  expect_type(hello(), "character")
})

test_that("hello() returns a single (scalar) value", {
  expect_length(hello(), 1L)
})

test_that("hello() returns a non-empty, non-NA string", {
  result <- hello()
  expect_false(is.na(result))
  expect_gt(nchar(result), 0L)
})

test_that("hello() returns the expected greeting", {
  expect_equal(hello(), "hello, brilliant world! (dev contribution)")
})

test_that("hello() output starts with a greeting", {
  expect_match(hello(), "^hello", ignore.case = TRUE)
})

test_that("hello() is deterministic across calls", {
  expect_identical(hello(), hello())
})

test_that("hello() takes no arguments", {
  expect_length(formals(hello), 0L)
})

test_that("hello() does not error", {
  expect_no_error(hello())
})
