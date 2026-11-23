# With Remotes, ospsuite.utils must be the GitHub development build
# (x.y.z.NNNN). Without Remotes (release form), it must be the R-universe
# release build (x.y.z).
test_that("ospsuite.utils comes from the source the DESCRIPTION declares", {
  remotes <- utils::packageDescription("WorkflowsTestPkg")$Remotes
  has_remotes <- !is.null(remotes) && nzchar(trimws(remotes))
  dep <- utils::packageVersion("ospsuite.utils")
  message(
    "WorkflowsTestPkg ", utils::packageVersion("WorkflowsTestPkg"),
    ", Remotes: ", if (has_remotes) "yes" else "no",
    ", ospsuite.utils ", dep
  )
  expect_length(unlist(dep), if (has_remotes) 4L else 3L)
})
