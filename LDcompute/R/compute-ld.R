#' Compute LD among variants
#'
#' @param gds A SeqArray GDS file
#' @param variant_include_1 A vector of variant ids. See details.
#' @param variant_include_2 A vector of variant.ids. See details.
#' @param methods A vector of methods to use to calculate LD. See details.
#' @param sample_include A vector of sample.ids to use for LD calculation.
#'
#' @details
#' This function is primarily a wrapper around the SNPRelate snpgdsLDMat function.
#' It allows LD calculations between a pair of variants, one variant and a set of other variants, and all pairs within a set of variants,
#' and returns results in a consistent format.
#'
#' The type of LD calculation is determined by how `variant_include_1` and `variant_include_2` are set.
#' * a pair of variants: set `variant.id.1` to one variant.id in the pair and `variant.id.2` to the other variant.id in the pair.
#' * one variant and a set of other variants: set `variant.id.1` to the variant.id and `variant.id.2` to the variant.ids for which LD should be calculated with respect to `variant.id.1`
#' * all pairs in a set of variants: set `variant.id.1` to a vector of variant ids and leave `variant.id.2` as `NULL`.
#'
#' @return
#' A data frame with the following columns:
#' * variant.id.1: the first variant id in the pair
#' * variant.id.2: the second variant id in the pair
#' * One column for each method specified giving the LD btween `variant.id.1` and `variant.id.2` using the specified method:
#'     * if `methods` contains `"composite"`: `ld_composite`
#'     * if `methods` contains `dprime`: `"ld_dprime"`
#'     * if `methods` contains `"corr"`: `ld_corr`
#'     * if `methods` contains `"r"`: `ld_r`
#'
#' Each pair of variants only has one record in the data frame.
#'
#' @md
#'
#' @importFrom SNPRelate snpgdsLDMat
#' @importFrom dplyr left_join %>% filter .data
#' @importFrom tidyr %>%
#' @importFrom tibble tibble %>%


compute_ld_pair <- function (gds, variant_include_1, variant_include_2, methods = "composite", sample_include = NULL) {

    # Checks - to be written.
    .check_ld_methods(methods)

    variant_include <- unique(c(variant_include_1, variant_include_2))

    .check_ld_multiallelic(gds, variant_include)


    res_list <- list()
    for (method in methods) {
      # Calculate ld between all pairs of variants provided.
      dat <- .compute_ld_matrix(gds, variant_include, method, sample_include = sample_include) %>%
          filter(.data$variant.id.1 == variant_include_1, .data$variant.id.2 == variant_include_2)
      res_list[[method]] <- dat
    }

    # This will be slow.
    # We can probably speed it up by just adding columns to the final data frame.
    # Need to check that variant.id.1 and variant.id.2 are the same from all methods.
    res <- res_list[[1]]
    if (length(methods) > 1) {
      for (i in 2:length(methods)) {
        res <- res %>%
          left_join(res_list[[i]], by = c("variant.id.1", "variant.id.2"))
      }
    }
    res

}

compute_ld_set <- function(gds, variant_include, methods = "composite", sample_include = NULL) {

  # Checks - to be written.
  .check_ld_methods(methods)

  # Handle duplicated variants.
  variant_include <- unique(variant_include)

  .check_ld_multiallelic(gds, variant_include)

  res_list <- list()
  for (method in methods) {
    # Calculate ld between all pairs of variants provided.
    dat <- .compute_ld_matrix(gds, variant_include, method, sample_include = sample_include) %>%
        filter(.data$variant.id.1 < .data$variant.id.2)
    res_list[[method]] <- dat
  }

  # This will be slow.
  # We can probably speed it up by just adding columns to the final data frame.
  # Need to check that variant.id.1 and variant.id.2 are the same from all methods.
  res <- res_list[[1]]
  if (length(methods) > 1) {
    for (i in 2:length(methods)) {
      res <- res %>%
        left_join(res_list[[i]], by = c("variant.id.1", "variant.id.2"))
    }
  }
  res

}

compute_ld_index <- function (gds, reference_variant, variant_include, methods = "composite", sample_include = NULL) {

  # Checks - to be written.
  .check_ld_methods(methods)

  all_variants <- unique(c(reference_variant, variant_include))

  .check_ld_multiallelic(gds, all_variants)

  res_list <- list()
  for (method in methods) {
    # Calculate ld between all pairs of variants provided.
    dat <- .compute_ld_matrix(gds, all_variants, method, sample_include = sample_include) %>%
      filter(
        .data$variant.id.1 == reference_variant, .data$variant.id.2 %in% variant_include,
        # not with itself.
        .data$variant.id.1 != .data$variant.id.2
      )
    res_list[[method]] <- dat
  }
  # This will be slow.
  # We can probably speed it up by just adding columns to the final data frame.
  # Need to check that variant.id.1 and variant.id.2 are the same from all methods.
  res <- res_list[[1]]
  if (length(methods) > 1) {
    for (i in 2:length(methods)) {
      res <- res %>%
        left_join(res_list[[i]], by = c("variant.id.1", "variant.id.2"))
    }
  }
  res

}

# Helper functions.
.compute_ld_matrix <- function(gds, variant_include, method, methods = "composite", sample_include = NULL) {
  # Calculate ld between all pairs of variants provided.
  ## This will be memory intensive if calculating LD for many variant.ids.
  ## Could fix by looping over blocks of variants.
  ld <- snpgdsLDMat(gds, snp.id = variant_include, sample.id = sample_include, slide = -1, verbose = FALSE, method = method)
  tmp <- ld$LD

  # Convert to data frame.
  dat <- tibble::tibble(
    variant.id.1 = rep(ld$snp.id, each = length(variant_include)),
    variant.id.2 = rep(ld$snp.id, times = length(variant_include)),
    ld = as.vector(ld$LD)
  )

  # Set names to reflect ld method.
  names(dat)[names(dat) == "ld"] <- sprintf("ld_%s", method)

  dat
}

.check_ld_methods <- function(methods) {
  ## Check that method is allowed
  allowed_methods <- c("composite", "dprime", "corr", "r")
  if (!all(methods %in% allowed_methods)) {
    msg <- sprintf("method is not in set of allowed methods: %s",
                   paste(allowed_methods, collapse = ", "))
    stop(msg)
  }
}

.check_ld_multiallelic <- function(gds, variant_include){
  # Check for multiallelic variants.
  seqSetFilter(gds, variant.id = variant_include, verbose = FALSE)
  if (any(nAlleles(gds) > 2)) {
    warning("multiallelic variants specified; LD calculation is not specific to each alternate allele.")
  }
  seqResetFilter(gds, verbose = FALSE)

}
