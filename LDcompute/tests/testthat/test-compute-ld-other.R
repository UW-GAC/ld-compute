# Tests of input checking or other standard checks regardless of which calculation is being done.

test_that("multiple variant_include_1 and non-null variant_id_2", {
  gds <- local_gds()
  var1 <- c(1, 2, 3)
  var2 <- c(4, 5, 6)
  expect_error(compute_ld(gds, variant_include_1 = var1, variant_include_2 = var2),
               "variant_include_2 must be NULL")
})

test_that("variant_include_1 has one variant and variant_id_2 is not specified", {
  gds <- local_gds()
  expect_error(compute_ld(gds, variant_include_1 = 1, variant_include_2 = NULL),
               "variant_include_2 must be specified if variant_include_1 contains one variant")
})

test_that("non-existing sample_include", {
  gds <- local_gds()
  sample_include <- letters[1:10]
  var_include <- c(1, 2, 3)
  expect_error(compute_ld(gds, variant_include_1 = var_include, sample_include = sample_include),
               "sample.id")
})

test_that("non-existing variant_include", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  var_include <- max(variant_ids) + c(1, 2)
  expect_error(compute_ld(gds, variant_include_1 = var_include), "snp.id")

  var1 <- 1
  var2 <- max(variant_ids) + c(1, 2)
  expect_error(compute_ld(gds, variant_include_1 = var1, variant_include_2 = var2), "snp.id")
})

test_that("warning with multiallelic variants", {
  gds <- local_gds()
  variant_ids <- seqGetData(gds, "variant.id")
  multi <- which(nAlleles(gds) > 2)
  bi <- which(nAlleles(gds) == 2)

  expect_warning(compute_ld(gds, variant_include_1 = multi[1], variant_include_2 = bi[1]), "multiallelic")
  expect_warning(compute_ld(gds, variant_include_1 = bi[1], variant_include_2 = multi[1]), "multiallelic")
  expect_warning(compute_ld(gds, variant_include_1 = c(multi[1], bi[1])), "multiallelic")
  expect_warning(compute_ld(gds, variant_include_1 = c(bi[1], multi[1])), "multiallelic")
})
