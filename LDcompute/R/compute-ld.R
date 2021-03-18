compute_ld <- function(gds, variant_include_1, variant_include_2 = NULL) {

  # Checks - to be written.
  # Choose which method to call - to be written.

  # Compute LD for a pair of variants.
  .compute_ld_one_to_one(gds, variant_include_1, variant_include_2)

}

# Computes LD between a pair of variants.
.compute_ld_one_to_one <- function(gds, variant_include_1, variant_include_2, method = "composite") {

  ld <- snpgdsLDMat(gds, snp.id = c(variant_include_1, variant_include_2),
                    slide = -1, verbose = FALSE)

  tibble::tibble(
    variant.id.1 = variant_include_1,
    variant.id.2 = variant_include_2,
    ld_composite = ld$LD[1,2]
  )
}

# Computes LD between one variant and a set of other variants.
.compute_ld_one_to_many <- function() {}

# Computes LD between all pairs of a set of variants.
.compute_ld_many_to_many <- function() {}
