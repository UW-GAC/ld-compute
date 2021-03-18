compute_ld <- function(gds, variant_include_1, variant_include_2 = NULL, methods = c("composite")) {

  # Checks - to be written.

  # Check that method is allowed

  allowed_methods <- c("composite", "dprime", "corr", "r")
  if (!(methods %in% allowed_methods)) {
    msg <- sprintf("method is not in set of allowed methods: %s",
                   paste(allowed_methods, collapse = ", "))
    stop(msg)
  }

  # Choose which method to call - to be written.

  # Compute LD for a pair of variants.
  .compute_ld_one_to_one(gds, variant_include_1, variant_include_2, methods = methods)

}

# Computes LD between a pair of variants.
.compute_ld_one_to_one <- function(gds, variant_include_1, variant_include_2, methods = "composite") {

  # For variant.ids with multiple alternate alleles, I think that snpgdsLDMat
  # just uses the ref dosage to calculate LD.
  ld <- snpgdsLDMat(gds, snp.id = c(variant_include_1, variant_include_2),
                    method = methods, slide = -1, verbose = FALSE)

  dat <- tibble::tibble(
    variant.id.1 = variant_include_1,
    variant.id.2 = variant_include_2,
    ld = ld$LD[1,2]
  )
  names(dat)[names(dat) == "ld"] <- sprintf("ld_%s", methods)
  dat
}

# Computes LD between one variant and a set of other variants.
.compute_ld_one_to_many <- function() {}

# Computes LD between all pairs of a set of variants.
.compute_ld_many_to_many <- function() {}
