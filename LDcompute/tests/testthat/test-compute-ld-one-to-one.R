test_that("works normally", {
  gds <- local_gds()
  var1 <- 1
  var2 <- 2
  ld <- compute_ld(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), slide = -1, verbose = FALSE)
  expect_equal(unname(ld$ld_composite), chk$LD[1,2])
})

test_that("returns ids in the correct order", {
  gds <- local_gds()
  var1 <- 2
  var2 <- 1
  ld <- compute_ld(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), slide = -1, verbose = FALSE)
  expect_equal(unname(ld$ld_composite), chk$LD[1,2])
})

test_that("missing data", {})

test_that("multiallelic variants", {})

test_that("multiple methods", {})

test_that("different chromosomes", {})
