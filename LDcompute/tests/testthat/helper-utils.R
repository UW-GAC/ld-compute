# Helper function to return the test gds file, and make sure that it's closed on exit.
local_gds <- function(env = parent.frame()) {
  filename <- system.file("extdata", "1KG_phase3_subset.gds", package="LDcompute")
  gds <- seqOpen(filename)
  # Make sure to close the gds file when the function exits.
  withr::defer(seqClose(gds), env)

  gds
}
