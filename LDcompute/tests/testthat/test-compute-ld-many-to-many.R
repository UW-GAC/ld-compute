library(SeqArray)
library(SNPRelate)

test_that("works normally with two variants", {
  gds <- local_gds()
  var_include <- c(1, 2)
  ld <- compute_ld_set(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, min(var_include))
  expect_equal(ld$variant.id.2, max(var_include))
  expect_true(is.numeric(ld$ld_r2))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var_include), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r2, chk$LD[1,2]^2)
})

test_that("returns variant ids in correct order with 2 and 10", {
  gds <- local_gds()
  var_include <- c(2, 10)
  ld <- compute_ld_set(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, 2)
  expect_equal(ld$variant.id.2, 10)
  expect_true(is.numeric(ld$ld_r2))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var_include), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r2, chk$LD[1,2]^2)
})

test_that("works normally with three variants", {
  gds <- local_gds()
  var_include <- c(1, 2, 3)
  ld <- compute_ld_set(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 3) # 3! / 2
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  expect_true(is.numeric(ld$ld_r2))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(var_include), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r2[1], chk$LD[1,2]^2)
  expect_equal(ld$ld_r2[2], chk$LD[1,3]^2)
  expect_equal(ld$ld_r2[3], chk$LD[2,3]^2)
})

test_that("100 random variants on chr22", {
  gds <- local_gds()
  seqSetFilterChrom(gds, 22, verbose=FALSE)
  var_include <- sample(seqGetData(gds, "variant.id")[nAlleles(gds) == 2], 100)
  seqResetFilter(gds, verbose = FALSE)
  ld <- compute_ld_set(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 100 * 99 / 2)
  expect_true(all(is.numeric(ld$ld_r2)))
})

test_that("returns variant ids in a standardized order", {
  gds <- local_gds()
  var_include <- c(2, 1, 3)
  ld_chk <- compute_ld_set(gds, c(1, 2, 3))
  ld <- compute_ld_set(gds, c(2, 1, 3))

  expect_equal(ld, ld_chk)
})

test_that("missing data", {
  gds <- local_gds()
  missing_rate <- missingGenotypeRate(gds, "by.variant")
  variant_ids <- seqGetData(gds, "variant.id")
  var_missing <- variant_ids[missing_rate > 0][1]
  var_nomiss <- variant_ids[missing_rate == 0][1]

  ld <- compute_ld_set(gds, c(var_missing, var_nomiss))
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 1)
  expect_true(is.numeric(ld$ld_r2))
  expect_true(!is.na(ld$ld_r2))
})

test_that("multiallelic variants", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  var_multi <- variant_ids[nAlleles(gds) > 2][1]
  var_bi <- variant_ids[nAlleles(gds) == 2][1]

  expect_warning(ld <- compute_ld_set(gds, c(var_multi, var_bi)), "multiallelic")

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 1)
  chk <- snpgdsLDMat(gds, snp.id = c(var_multi, var_bi), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r2, chk$LD[1,2]^2)
})

test_that("different methods", {
  # Use a different method to calculate LD.
  gds <- local_gds()
  var_include <- c(1, 2, 3)

  ld <- compute_ld_set(gds, var_include, ld_methods = "r2")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  chk <- snpgdsLDMat(gds, snp.id = var_include, method = "corr", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r2, chk$LD[upper.tri(chk$LD)]^2)

  ld <- compute_ld_set(gds, var_include, ld_methods = "dprime")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_dprime"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  chk <- snpgdsLDMat(gds, snp.id = var_include, method = "dprime", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_dprime, chk$LD[upper.tri(chk$LD)])

  ld <- compute_ld_set(gds, var_include, ld_methods = "r")
  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  chk <- snpgdsLDMat(gds, snp.id = var_include, method = "corr", slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r, chk$LD[upper.tri(chk$LD)])

  # Method not allowed.
  expect_error(compute_ld_set(gds, var_include, ld_methods = "foo"), "allowed methods")

})

test_that("multiple methods are allowed", {
  # Use a different method to calculate LD.
  gds <- local_gds()
  var_include <- c(1, 2, 3)

  ld_r2 <- compute_ld_set(gds, var_include, ld_methods = "r2")
  ld_dprime <- compute_ld_set(gds, var_include, ld_methods = "dprime")
  ld_r <- compute_ld_set(gds, var_include, ld_methods = "r")

  ld_full <- compute_ld_set(gds, var_include, ld_methods = c("r2", "dprime", "r"))
  expect_equal(names(ld_full), c("variant.id.1", "variant.id.2", "ld_r2", "ld_dprime", "ld_r"))
  expect_equal(ld_full$variant.id.1, c(1, 1, 2))
  expect_equal(ld_full$variant.id.2, c(2, 3, 3))
  expect_equal(ld_full$ld_r2, ld_r2$ld_r2)
  expect_equal(ld_full$ld_dprime, ld_dprime$ld_dprime)
  expect_equal(ld_full$ld_r, ld_r$ld_r)

  # Method not allowed.
  expect_error(compute_ld_set(gds, var1, var2, ld_methods = c("r", "foo")), "allowed methods")
})

test_that("different chromosomes", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  chr <- seqGetData(gds, "chromosome")
  var_include <- c(variant_ids[chr == 1][1], variant_ids[chr == 2][1])
  ld <- compute_ld_set(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 1)
  expect_equal(ld$variant.id.1, min(var_include))
  expect_equal(ld$variant.id.2, max(var_include))
  expect_true(is.numeric(ld$ld_r2))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = var_include, slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r2, chk$LD[1,2]^2)
})

test_that("sample set", {
  gds <- local_gds()
  sample_ids <- seqGetData(gds, "sample.id")
  sample_include <- sample_ids[1:500]
  var_include <- c(1, 2, 3)
  ld_all <- compute_ld_set(gds, var_include)
  ld_sub <- compute_ld_set(gds, var_include, sample_include = sample_include)

  expect_equal(names(ld_sub), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld_sub), 3)
  expect_equal(ld_sub$variant.id.1, c(1, 1, 2))
  expect_equal(ld_sub$variant.id.2, c(2, 3, 3))
  expect_true(all(is.numeric(ld_sub$ld_r2)))

  # Different than with all samples together.
  expect_true(all(ld_sub$ld_r2 != ld_all$ld_r2))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = var_include, sample.id=sample_include, slide = -1, verbose = FALSE)
  expect_equal(ld_sub$ld_r2, chk$LD[upper.tri(chk$LD)]^2)
})

test_that("works with large variant ids", {
  gds <- local_gds()
  ld <- compute_ld_set(gds, c(10000, 10003, 10004))

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(10000, 10000, 10003))
  expect_equal(ld$variant.id.2, c(10003, 10004, 10004))
  expect_true(is.numeric(ld$ld_r2))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(10000, 10003, 10004), slide = -1, verbose = FALSE)$LD^2
  expect_equal(ld$ld_r2[1], chk[1,2])
  expect_equal(ld$ld_r2[2], chk[1,3])
  expect_equal(ld$ld_r2[3], chk[2,3])
})

test_that("duplicated variant ids", {
  gds <- local_gds()
  var_include <- c(1, 1, 2, 3)
  ld <- compute_ld_set(gds, var_include)

  expect_equal(names(ld), c("variant.id.1", "variant.id.2", "ld_r2"))
  expect_equal(nrow(ld), 3)
  expect_equal(ld$variant.id.1, c(1, 1, 2))
  expect_equal(ld$variant.id.2, c(2, 3, 3))
  expect_true(is.numeric(ld$ld_r2))

  # Check against the function directly.
  chk <- snpgdsLDMat(gds, snp.id = c(1, 2, 3), slide = -1, verbose = FALSE)
  expect_equal(ld$ld_r2[1], chk$LD[1,2]^2)
  expect_equal(ld$ld_r2[2], chk$LD[1,3]^2)
  expect_equal(ld$ld_r2[3], chk$LD[2,3]^2)
})

test_that("non-existing sample_include", {
  gds <- local_gds()
  sample_include <- letters[1:10]
  var_include <- c(1, 2, 3)
  expect_error(compute_ld_set(gds, var_include, sample_include = sample_include),
               "sample.id")
})

test_that("non-existing variant_include", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  var_include <- max(variant_ids) + c(1, 2)
  expect_error(compute_ld_set(gds, var_include), "snp.id")
})

test_that("warning with multiallelic variants", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  multi <- variant_ids[nAlleles(gds) > 2]
  bi <- variant_ids[nAlleles(gds) == 2]

  expect_warning(compute_ld_set(gds, c(multi[1], bi[1])), "multiallelic")
})


test_that("same results as other ld functions for same variants", {
  gds <- local_gds()
  ld <- compute_ld_set(gds, c(1, 2))
  expect_equal(ld, compute_ld_pair(gds, 1, 2))
  expect_equal(ld, compute_ld_index(gds, 1, 2))
})

test_that("checks variant input", {
  gds <- local_gds()
  expect_error(compute_ld_set(gds, 1), "more than one variant.id")
  expect_error(compute_ld_set(gds, c(1, 1)), "more than one variant.id")
})
