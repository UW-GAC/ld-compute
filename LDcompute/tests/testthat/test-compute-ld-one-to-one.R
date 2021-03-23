library(SeqArray)
library(SNPRelate)

test_that("works normally", {
  gds <- local_gds()
  var1 <- 1
  var2 <- 2
  ld <- compute_ld_pair(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite, chk$LD[1,2])
})

test_that("returns ids in the correct order", {
  gds <- local_gds()
  var1 <- 2
  var2 <- 1
  ld <- compute_ld_pair(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite, chk$LD[1,2])
})

test_that("returns variant ids in correct order with 2 and 10", {
  gds <- local_gds()
  var1 <- 2
  var2 <- 10
  ld <- compute_ld_pair(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite, chk$LD[1,2])
})

test_that("missing data", {
  gds <- local_gds()
  missing_rate <- SeqVarTools::missingGenotypeRate(gds, "by.variant")
  var1 <- which(missing_rate > 0)[1]
  var2 <- 1

  ld <- compute_ld_pair(gds, var1, var2)

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

  expect_warning(ld <- compute_ld_pair(gds, var1, var2), "multiallelic")

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

  ld <- compute_ld_pair(gds, var1, var2, methods = "composite")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), method = "composite", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite, chk$LD[1,2])

  ld <- compute_ld_pair(gds, var1, var2, methods = "dprime")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_dprime"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), method = "dprime", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_dprime, chk$LD[1,2])

  ld <- compute_ld_pair(gds, var1, var2, method = "corr")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_corr"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), method = "corr", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_corr, chk$LD[1,2])

  ld <- compute_ld_pair(gds, var1, var2, method = "r")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), method = "r", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r, chk$LD[1,2])

  # Method not allowed.
  expect_error(compute_ld_pair(gds, var1, var2, method = "foo"), "allowed methods")

})

test_that("multiple methods are allowed", {
  # Use a different method to calculate LD.
  gds <- local_gds()
  var1 <- 1
  var2 <- 2

  ld_composite <- compute_ld_pair(gds, var1, var2, methods = "composite")
  ld_dprime <- compute_ld_pair(gds, var1, var2, methods = "dprime")
  ld_corr <- compute_ld_pair(gds, var1, var2, method = "corr")
  ld_r <- compute_ld_pair(gds, var1, var2, method = "r")

  ld_full <- compute_ld_pair(gds, var1, var2, methods = c("composite", "dprime", "corr", "r"))
  expect_equal(names(ld_full), c("variant.id.1", "variant.id.2", "ld_composite", "ld_dprime", "ld_corr", "ld_r"))
  expect_equal(ld_full$variant.id.1, var1)
  expect_equal(ld_full$variant.id.2, var2)
  expect_equal(ld_full$ld_composite, ld_composite$ld_composite)
  expect_equal(ld_full$ld_dprime, ld_dprime$ld_dprime)
  expect_equal(ld_full$ld_corr, ld_corr$ld_corr)
  expect_equal(ld_full$ld_r, ld_r$ld_r)


  # Method not allowed.
  expect_error(compute_ld_pair(gds, var1, var2, method = c("r", "foo")), "allowed methods")
 })

test_that("different chromosomes", {
  skip("what do we want to happen?")
})

test_that("sample set", {
  gds <- local_gds()
  sample_ids <- seqGetData(gds, "sample.id")
  sample_include <- sample_ids[1:500]
  var1 <- 1
  var2 <- 2
  ld_all <- compute_ld_pair(gds, var1, var2)
  ld_sub <- compute_ld_pair(gds, var1, var2, sample_include = sample_include)

  expect_equal(names(ld_sub), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld_sub), 1)
  expect_equal(ld_sub$variant.id.1, var1)
  expect_equal(ld_sub$variant.id.2, var2)
  expect_true(is.numeric(ld_sub$ld_composite))

  # Different than with all samples together.
  expect_true(ld_sub$ld_composite != ld_all$ld_composite)

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), sample.id=sample_include, slide = -1, verbose = FALSE)
  expect_equal(ld_sub$ld_composite, chk$LD[1,2])
})

test_that("works with large variant ids", {
  gds <- local_gds()
  var1 <- 1
  var2 <- 10000
  ld <- compute_ld_pair(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, 1)
  expect_equal(ld$variant.id.2, 10000)
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(1, 10000), slide = -1, verbose = FALSE)$LD
  expect_equal(ld$ld_composite, chk[1, 2])
})

test_that("random set of variants", {
  gds <- local_gds()
  seqSetFilterChrom(gds, 22, verbose = FALSE)
  variant_ids <- seqGetData(gds, "variant.id")
  seqResetFilter(gds, verbose = FALSE)
  var1 <- sample(variant_ids, 1)
  var2 <- sample(setdiff(variant_ids, var1), 1)
  ld <- compute_ld_pair(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, var1)
  expect_equal(ld$variant.id.2, var2)
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var1, var2), slide = -1, verbose = FALSE)$LD
  expect_equal(ld$ld_composite, chk[1, 2])
})

test_that("non-existing sample_include", {
  gds <- local_gds()
  sample_include <- letters[1:10]
  expect_error(compute_ld_pair(gds, 1, 2, sample_include = sample_include),
               "sample.id")
})

test_that("non-existing variant_include", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  max_var <- max(variant_ids)
  expect_error(compute_ld_pair(gds, max_var + 1, max_var + 2), "snp.id")
  expect_error(compute_ld_pair(gds, 1, max_var + 1), "snp.id")
  expect_error(compute_ld_pair(gds, max_var + 1, 1), "snp.id")
})

test_that("warning with multiallelic variants", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  multi <- which(nAlleles(gds) > 2)
  bi <- which(nAlleles(gds) == 2)

  expect_warning(compute_ld_pair(gds, multi[1], bi[1]), "multiallelic")
  expect_warning(compute_ld_pair(gds, bi[1], multi[1]), "multiallelic")
})

test_that("same results as other ld functions for same variants", {
  gds <- local_gds()
  ld <- compute_ld_pair(gds, 1, 2)
  expect_equal(ld, compute_ld_index(gds, 1, 2))
  expect_equal(ld, compute_ld_set(gds, c(1, 2)))
})

test_that("checks variant input", {
  gds <- local_gds()
  var1 <- c(1, 2)
  var2 <- 3
  # Multple ids
  expect_error(compute_ld_pair(gds, c(1, 2), 3), "only one variant.id")
  expect_error(compute_ld_pair(gds, 3, c(1, 2)), "only one variant.id")
  # same id
  expect_error(compute_ld_pair(gds, 1, 1), "different variant.ids")
  expect_error(compute_ld_pair(gds, 1, c(1, 1)), "only one variant.id")
})
