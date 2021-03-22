#' Compute LD between a pair of variants
#'
#' @param gds A SeqArray GDS file
#' @param variant_id_1 First variant id in the pair
#' @param variant_id_2 Second variant id in the pair
#' @param methods Character vector of methods to use to calculate LD. Can be any of `"composite"`, `"corr"`, `"r"`, `"dprime"`.
#' @param sample_include A vector of sample.ids to use for LD calculation.
#'
#' @details
#' This function computes the LD between two variants using \code{snpgdsLDMat} using the specified methods.
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
#' @importFrom SeqArray seqSetFilter seqResetFilter
#' @importFrom SNPRelate snpgdsLDMat
#' @importFrom dplyr left_join %>% filter .data
#'
#' @seealso
#' * [compute_ld_pair()] computes LD between a pair of variants
#' * [compute_ld_set()] computes LD between all pairs of a set of variants
#' * [compute_ld_index()] computes LD between one variant and a set of other variants
compute_ld_pair <- function (gds, variant_id_1, variant_id_2, methods = "composite", sample_include = NULL) {

    # Checks - to be written.
    .check_ld_methods(methods)

    variant_include <- unique(c(variant_id_1, variant_id_2))

    .check_ld_multiallelic(gds, variant_include)


    res_list <- list()
    for (method in methods) {
      # Calculate ld between all pairs of variants provided.
      dat <- .compute_ld_matrix(gds, variant_include, method, sample_include = sample_include) %>%
          filter(.data$variant.id.1 == variant_id_1, .data$variant.id.2 == variant_id_2)
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


#' Compute LD among all pairs of a set of variants
#'
#' @inheritParams compute_ld_pair
#' @param variant_include THe variant.ids for which to calculate ld
#'
#' @details
#' This function computes the LD between all pairs in a set of variants using \code{snpgdsLDMat} using the specified methods.
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
#' @importFrom SeqArray seqSetFilter seqResetFilter
#' @importFrom SNPRelate snpgdsLDMat
#' @importFrom dplyr left_join %>% filter .data
#'
#' @seealso
#' * [compute_ld_pair()] computes LD between a pair of variants
#' * [compute_ld_set()] computes LD between all pairs of a set of variants
#' * [compute_ld_index()] computes LD between one variant and a set of other variants
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


#' Compute LD among one index variant and a set of other variants
#'
#' @inheritParams compute_ld_pair
#' @param index_variant_id The variant.id of the index variant
#' @param other_variant_ids A vector of variant ids to calculate LD with the `index_variant_id`
#'
#' @details
#' This function computes the LD between `index_variant_id` and the variant ids specified in `other_variant_ids`.
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
#' @importFrom SeqArray seqSetFilter seqResetFilter
#' @importFrom SNPRelate snpgdsLDMat
#' @importFrom dplyr left_join %>% filter .data
#'
#' @seealso
#' * [compute_ld_pair()] computes LD between a pair of variants
#' * [compute_ld_set()] computes LD between all pairs of a set of variants
#' * [compute_ld_index()] computes LD between one variant and a set of other variants
compute_ld_index <- function (gds, index_variant_id, other_variant_ids, methods = "composite", sample_include = NULL) {

  # Checks - to be written.
  .check_ld_methods(methods)

  variant_include <- unique(c(index_variant_id, other_variant_ids))

  .check_ld_multiallelic(gds, variant_include)

  res_list <- list()
  for (method in methods) {
    # Calculate ld between all pairs of variants provided.
    dat <- .compute_ld_matrix(gds, variant_include, method, sample_include = sample_include) %>%
      filter(
        .data$variant.id.1 == index_variant_id, .data$variant.id.2 %in% other_variant_ids,
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
# Compute LD across a set of variants
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

# Check that a specified LD method is allowed
.check_ld_methods <- function(methods) {
  ## Check that method is allowed
  allowed_methods <- c("composite", "dprime", "corr", "r")
  if (!all(methods %in% allowed_methods)) {
    msg <- sprintf("method is not in set of allowed methods: %s",
                   paste(allowed_methods, collapse = ", "))
    stop(msg)
  }
}

# Handle multiallelic variants
.check_ld_multiallelic <- function(gds, variant_include){
  # Check for multiallelic variants.
  seqSetFilter(gds, variant.id = variant_include, verbose = FALSE)
  if (any(SeqVarTools::nAlleles(gds) > 2)) {
    warning("multiallelic variants specified; LD calculation is not specific to each alternate allele.")
  }
  seqResetFilter(gds, verbose = FALSE)

}
