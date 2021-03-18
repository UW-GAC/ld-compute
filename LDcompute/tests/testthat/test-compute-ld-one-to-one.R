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

test_that("missing data", {
  gds <- local_gds()
  missing_rate <- SeqVarTools::missingGenotypeRate(gds, "by.variant")
  var1 <- which(missing_rate > 0)[1]
  var2 <- 1

  ld <- compute_ld(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  expect_true(is.numeric(ld$ld_composite))
  expect_true(!is.na(ld$ld_composite))
})

test_that("multiallelic variants", {
  gds <- local_gds()
  missing_rate <- SeqVarTools::missingGenotypeRate(gds, "by.variant")
  var1 <- which(nAlleles(gds) > 2)[1]
  var2 <- which(nAlleles(gds) == 2)[1]

  ld <- compute_ld(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  expect_true(is.numeric(ld$ld_composite))
  expect_true(!is.na(ld$ld_composite))
})

test_that("different methods", {
  # Use a different method to calculate LD.
  gds <- local_gds()
  var1 <- 1
  var2 <- 2

  ld <- compute_ld(gds, var1, var2, methods = "composite")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), method = "composite", slide = -1, verbose = FALSE)
  expect_equal(unname(ld$ld_composite), chk$LD[1,2])

  ld <- compute_ld(gds, var1, var2, methods = "dprime")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_dprime"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), method = "dprime", slide = -1, verbose = FALSE)
  expect_equal(unname(ld$ld_dprime), chk$LD[1,2])

  ld <- compute_ld(gds, var1, var2, method = "corr")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_corr"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), method = "corr", slide = -1, verbose = FALSE)
  expect_equal(unname(ld$ld_corr), chk$LD[1,2])

  ld <- compute_ld(gds, var1, var2, method = "r")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), method = "r", slide = -1, verbose = FALSE)
  expect_equal(unname(ld$ld_r), chk$LD[1,2])

  # Method not allowed.
  expect_error(compute_ld(gds, var1, var2, method = "foo"), "allowed methods")

})

test_that("different chromosomes", {
  fail("what do we want to happen?")
})
