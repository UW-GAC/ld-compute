#' Compute LD between a pair of variants
#'
#' @param gds A SeqArray GDS file
#' @param variant_id_1 First variant id in the pair
#' @param variant_id_2 Second variant id in the pair
#' @param ld_methods Character vector of methods to use to calculate LD. Can be any of `"composite"`, `"corr"`, `"r"`, `"dprime"`.
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
#' @examples
#'
#' gds <- SeqArray::seqOpen(system.file("extdata", "1KG_phase3_subset.gds", package="LDcompute"))
#'
#' # Different methods
#' compute_ld_pair(gds, 1, 2, methods = "composite")
#' compute_ld_pair(gds, 1, 2, methods = "dprime")
#' compute_ld_pair(gds, 1, 2, methods = c("composite", "dprime"))
#'
#' # Different sample set
#' sample_include <- SeqArray::seqGetData(gds, "sample.id")[1:500]
#' compute_ld_pair(gds, 1, 2, methods = "composite", sample_include = sample_include)
#'
#' SeqArray::seqClose(gds)
#'
#' @md
#'
#' @export
#'
#' @importFrom SeqArray seqSetFilter seqResetFilter
#' @importFrom SNPRelate snpgdsLDMat
#' @importFrom dplyr left_join %>% filter .data
#'
#' @seealso
#' * [compute_ld_pair()] computes LD between a pair of variants
#' * [compute_ld_set()] computes LD between all pairs of a set of variants
#' * [compute_ld_index()] computes LD between one variant and a set of other variants
compute_ld_pair <- function (gds, variant_id_1, variant_id_2, ld_methods = "r2", sample_include = NULL) {

    # Checks - to be written.
    .check_ld_methods(ld_methods)

    # Check variant include
    if (length(variant_id_1) != 1) {
      stop("variant_id_1 must contain only one variant.id.")
    }
    if (length(variant_id_2) != 1) {
      stop("variant_id_1 must contain only one variant.id.")
    }
    if (variant_id_1 == variant_id_2) {
      stop("variant_id_1 and variant_id_2 must contain different variant.ids.")
    }
    variant_include <- unique(c(variant_id_1, variant_id_2))

    .check_ld_multiallelic(gds, variant_include)


    res_list <- list()
    for (ld_method in ld_methods) {
      # Calculate ld between all pairs of variants provided.
      dat <- .compute_ld_matrix(gds, variant_include, ld_method, sample_include = sample_include) %>%
          filter(.data$variant.id.1 == variant_id_1, .data$variant.id.2 == variant_id_2)
      res_list[[ld_method]] <- dat
    }

    .combine_ld_results(res_list)
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
#' @examples
#'
#' gds <- SeqArray::seqOpen(system.file("extdata", "1KG_phase3_subset.gds", package="LDcompute"))
#'
#' # Different methods
#' compute_ld_set(gds, c(1, 2, 3), methods = "composite")
#' compute_ld_set(gds, c(1, 2, 3), methods = "dprime")
#' compute_ld_set(gds, c(1, 2, 3), methods = c("composite", "dprime"))
#'
#' # Different sample set
#' sample_include <- SeqArray::seqGetData(gds, "sample.id")[1:500]
#' compute_ld_set(gds, c(1, 2, 3), methods = "composite", sample_include = sample_include)
#'
#' SeqArray::seqClose(gds)
#'
#' @md
#'
#' @export
#'
#' @importFrom SeqArray seqSetFilter seqResetFilter
#' @importFrom SNPRelate snpgdsLDMat
#' @importFrom dplyr left_join %>% filter .data
#'
#' @seealso
#' * [compute_ld_pair()] computes LD between a pair of variants
#' * [compute_ld_set()] computes LD between all pairs of a set of variants
#' * [compute_ld_index()] computes LD between one variant and a set of other variants
compute_ld_set <- function(gds, variant_include, ld_methods = "r2", sample_include = NULL) {

  # Checks - to be written.
  .check_ld_methods(ld_methods)

  # Handle duplicated variants.
  variant_include <- unique(variant_include)
  if (length(variant_include) == 1) {
    stop("variant_include must have more than one variant.id.")
  }

  .check_ld_multiallelic(gds, variant_include)

  res_list <- list()
  for (ld_method in ld_methods) {
    # Calculate ld between all pairs of variants provided.
    dat <- .compute_ld_matrix(gds, variant_include, ld_method, sample_include = sample_include) %>%
        filter(.data$variant.id.1 < .data$variant.id.2)
    res_list[[ld_method]] <- dat
  }

  .combine_ld_results(res_list)
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
#' @examples
#'
#' gds <- SeqArray::seqOpen(system.file("extdata", "1KG_phase3_subset.gds", package="LDcompute"))
#'
#' # Different methods
#' compute_ld_index(gds, 5, c(2:4, 6:8), methods = "composite")
#' compute_ld_index(gds, 5, c(2:4, 6:8), methods = "dprime")
#' compute_ld_index(gds, 5, c(2:4, 6:8), methods = c("composite", "dprime"))
#'
#' # Different sample set
#' sample_include <- SeqArray::seqGetData(gds, "sample.id")[1:500]
#' compute_ld_index(gds, 5, c(2:4, 6:8), methods = "composite", sample_include = sample_include)
#'
#' SeqArray::seqClose(gds)
#'
#' @md
#'
#' @export
#'
#' @importFrom SeqArray seqSetFilter seqResetFilter
#' @importFrom SNPRelate snpgdsLDMat
#' @importFrom dplyr left_join %>% filter .data
#'
#' @seealso
#' * [compute_ld_pair()] computes LD between a pair of variants
#' * [compute_ld_set()] computes LD between all pairs of a set of variants
#' * [compute_ld_index()] computes LD between one variant and a set of other variants
compute_ld_index <- function (gds, index_variant_id, other_variant_ids, ld_methods = "r2", sample_include = NULL) {

  # Checks - to be written.
  .check_ld_methods(ld_methods)

  # Check variant include
  if (length(index_variant_id) != 1) {
    stop("index_variant_id must contain only one variant.id.")
  }
  if (length(other_variant_ids) == 0) {
    stop("other_variant_ids must contain at least one variant.id.")
  }
  other_variant_ids <- unique(other_variant_ids)
  if (length(other_variant_ids) == 1 && index_variant_id == other_variant_ids) {
    # Same variant id passed for both index_variant_id and other_variant_ids
    stop("variant_id_1 and other_variant_ids must contain different variant.ids.")
  }
  variant_include <- unique(c(index_variant_id, other_variant_ids))

  .check_ld_multiallelic(gds, variant_include)

  res_list <- list()
  for (ld_method in ld_methods) {
    # Calculate ld between all pairs of variants provided.
    dat <- .compute_ld_matrix(gds, variant_include, ld_method, sample_include = sample_include) %>%
      filter(
        .data$variant.id.1 == index_variant_id, .data$variant.id.2 %in% other_variant_ids,
        # not with itself.
        .data$variant.id.1 != .data$variant.id.2
      )
    res_list[[ld_method]] <- dat
  }

  .combine_ld_results(res_list)
}

# Helper functions.
# Compute LD across a set of variants
.compute_ld_matrix <- function(gds, variant_include, ld_method, sample_include = NULL) {
  # Calculate ld between all pairs of variants provided.
  ## This will be memory intensive if calculating LD for many variant.ids.
  ## Could fix by looping over blocks of variants.

  # Determine correct SNPrelate method.
  snprel_method <- switch(ld_method,
    r2 = "corr",
    r = "corr",
    dprime = "dprime",
    stop("method not allowed")
  )

  ld <- snpgdsLDMat(gds, snp.id = variant_include, sample.id = sample_include, slide = -1, verbose = FALSE, method = snprel_method)
  tmp <- ld$LD

  # Convert to data frame.
  dat <- tibble::tibble(
    variant.id.1 = rep(ld$snp.id, each = length(variant_include)),
    variant.id.2 = rep(ld$snp.id, times = length(variant_include)),
    ld = as.vector(ld$LD)
  )

  if (ld_method == "r2") {
    dat$ld <- dat$ld^2
  }

  # Set names to reflect ld method.
  names(dat)[names(dat) == "ld"] <- sprintf("ld_%s", ld_method)

  dat
}

# Check that a specified LD method is allowed
.check_ld_methods <- function(methods) {
  ## Check that method is allowed
  #allowed_methods <- c("composite", "dprime", "corr", "r")
  allowed_methods <- c("r2", "r", "dprime")
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

# Combine results from multiple LD methods into one data frame.
.combine_ld_results <- function(res_list) {
  res <- res_list[[1]]
  if (length(res_list) > 1) {
    for (i in 2:length(res_list)) {
      if (all(res$variant.id.1 == res_list[[i]]$variant.id.1) &
          all(res$variant.id.2 == res_list[[i]]$variant.id.2)) {
        col <- names(res_list[[i]])[3]
        res[[col]] <- res_list[[i]][[col]]
      } else {
        stop("unexpected error")
      }
    }
  }
  res
}
