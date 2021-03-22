library(SeqArray)
library(SNPRelate)

test_that("works normally with two variants", {
  gds <- local_gds()
  var_include <- c(1, 2)
  ld <- compute_ld(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, min(var_include))
  expect_equal(ld$variant.id.2, max(var_include))
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var_include), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite, chk$LD[1,2])
})

test_that("returns variant ids in correct order with 2 and 10", {
  gds <- local_gds()
  var_include <- c(2, 10)
  ld <- compute_ld(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, 2)
  expect_equal(ld$variant.id.2, 10)
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var_include), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite, chk$LD[1,2])
})

test_that("works normally with three variants", {
  gds <- local_gds()
  var_include <- c(1, 2, 3)
  ld <- compute_ld(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 3) # 3! / 2
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var_include), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite[1], chk$LD[1,2])
  expect_equal(ld$ld_composite[2], chk$LD[1,3])
  expect_equal(ld$ld_composite[3], chk$LD[2,3])
})

test_that("100 random variants on chr22", {
  gds <- local_gds()
  seqSetFilterChrom(gds, 22, verbose=FALSE)
  var_include <- sample(seqGetData(gds, "variant.id")[nAlleles(gds) == 2], 100)
  seqResetFilter(gds, verbose = FALSE)
  ld <- compute_ld(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 100 * 99 / 2)
  expect_true(all(is.numeric(ld$ld_composite)))
})

test_that("returns variant ids in a standardized order", {
  gds <- local_gds()
  var_include <- c(2, 1, 3)
  ld_chk <- compute_ld(gds, c(1, 2, 3))
  ld <- compute_ld(gds, c(2, 1, 3))

  expect_equal(ld, ld_chk)
})

test_that("missing data", {
  gds <- local_gds()
  missing_rate <- missingGenotypeRate(gds, "by.variant")
  variant_ids <- seqGetData(gds, "variant.id")
  var_missing <- variant_ids[missing_rate > 0][1]
  var_nomiss <- variant_ids[missing_rate == 0][1]

  ld <- compute_ld(gds, c(var_missing, var_nomiss))
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  expect_true(is.numeric(ld$ld_composite))
  expect_true(!is.na(ld$ld_composite))
})

test_that("multiallelic variants", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  var_multi <- variant_ids[nAlleles(gds) > 2][1]
  var_bi <- variant_ids[nAlleles(gds) == 2][1]

  expect_warning(ld <- compute_ld(gds, c(var_multi, var_bi)), "multiallelic")

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 1)
  chk <- snpgdsLDMat(gds, snp.id = c(var_multi, var_bi), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite, chk$LD[1,2])
})

test_that("different methods", {
  # Use a different method to calculate LD.
  gds <- local_gds()
  var_include <- c(1, 2, 3)

  ld <- compute_ld(gds, var_include, methods = "composite")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  chk <- snpgdsLDMat(gds, snp.id = var_include, method = "composite", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite, chk$LD[upper.tri(chk$LD)])

  ld <- compute_ld(gds, var_include, methods = "dprime")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_dprime"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  chk <- snpgdsLDMat(gds, snp.id = var_include, method = "dprime", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_dprime, chk$LD[upper.tri(chk$LD)])

  ld <- compute_ld(gds, var_include, method = "corr")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_corr"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  chk <- snpgdsLDMat(gds, snp.id = var_include, method = "corr", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_corr, chk$LD[upper.tri(chk$LD)])

  ld <- compute_ld(gds, var_include, method = "r")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  chk <- snpgdsLDMat(gds, snp.id = var_include, method = "r", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r, chk$LD[upper.tri(chk$LD)])

  # Method not allowed.
  expect_error(compute_ld(gds, var_include, method = "foo"), "allowed methods")

})

test_that("multiple methods are allowed", {
  # Use a different method to calculate LD.
  gds <- local_gds()
  var_include <- c(1, 2, 3)

  ld_composite <- compute_ld(gds, var_include, methods = "composite")
  ld_dprime <- compute_ld(gds, var_include, methods = "dprime")
  ld_corr <- compute_ld(gds, var_include, method = "corr")
  ld_r <- compute_ld(gds, var_include, method = "r")

  ld_full <- compute_ld(gds, var_include, methods = c("composite", "dprime", "corr", "r"))
  expect_equal(names(ld_full), c("variant.id.1", "variant.id.2", "ld_composite", "ld_dprime", "ld_corr", "ld_r"))
  expect_equal(ld_full$variant.id.1, c(1, 1, 2))
  expect_equal(ld_full$variant.id.2, c(2, 3, 3))
  expect_equal(ld_full$ld_composite, ld_composite$ld_composite)
  expect_equal(ld_full$ld_dprime, ld_dprime$ld_dprime)
  expect_equal(ld_full$ld_corr, ld_corr$ld_corr)
  expect_equal(ld_full$ld_r, ld_r$ld_r)

  # Method not allowed.
  expect_error(compute_ld(gds, var1, var2, method = c("r", "foo")), "allowed methods")
})

test_that("different chromosomes", {
  skip("what do we want to happen?")
})

test_that("sample set", {
  gds <- local_gds()
  sample_ids <- seqGetData(gds, "sample.id")
  sample_include <- sample_ids[1:500]
  var_include <- c(1, 2, 3)
  ld_all <- compute_ld(gds, var_include)
  ld_sub <- compute_ld(gds, var_include, sample_include = sample_include)

  expect_equal(names(ld_sub), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld_sub), 3)
  expect_equal(ld_sub$variant.id.1, c(1, 1, 2))
  expect_equal(ld_sub$variant.id.2, c(2, 3, 3))
  expect_true(all(is.numeric(ld_sub$ld_composite)))

  # Different than with all samples together.
  expect_true(all(ld_sub$ld_composite != ld_all$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = var_include, sample.id=sample_include, slide = -1, verbose = FALSE)
  expect_equal(ld_sub$ld_composite, chk$LD[upper.tri(chk$LD)])
})

test_that("works with large variant ids", {
  gds <- local_gds()
  var1 <- 10000
  var2 <- c(10003, 10004)
  ld <- compute_ld(gds, var1, var2)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 2)
  expect_equal(ld$variant.id.1, c(10000, 10000))
  expect_equal(ld$variant.id.2, c(10003, 10004))
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(10000, 10003, 10004), slide = -1, verbose = FALSE)$LD
  expect_equal(ld$ld_composite, chk[1,2:3])
})

test_that("duplicated variant ids", {
  gds <- local_gds()
  var_include <- c(1, 1, 2, 3)
  ld <- compute_ld(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_composite"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  expect_true(is.numeric(ld$ld_composite))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(1, 2, 3), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_composite[1], chk$LD[1,2])
  expect_equal(ld$ld_composite[2], chk$LD[1,3])
  expect_equal(ld$ld_composite[3], chk$LD[2,3])
})
