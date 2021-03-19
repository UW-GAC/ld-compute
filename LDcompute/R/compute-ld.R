#' Compute LD among variants
#'
#' @param gds A SeqArray GDS file
#' @param variant_include_1 A vector of variant ids. See details.
#' @param variant_include_2 A vector of variant.ids. See details.
#' @param methods A vector of methods to use to calculate LD. See details.
#'
#' @details
#' This function is primarily a wrapper around the SNPRelate snpgdsLDMat function.
#' It allows LD calculations between a pair of variants and returns results in a consistent format.
#'
#' @value
#' A data frame with the following columns:
#' * variant.id.1: the first variant id in the pair
#' * variant.id.2: the second variant id in the pair
#' * (if `method="composite"``) ld_composite: the LD between variant.id.1 and variant.id.2 calculated using the "composite" method
#' * (if `method="dprime"``) ld_composite: the LD between variant.id.1 and variant.id.2 calculated using the "dprime" method
#' * (if `method="corr"``) ld_composite: the LD between variant.id.1 and variant.id.2 calculated using the "corr" method
#' * (if `method="r"``) ld_composite: the LD between variant.id.1 and variant.id.2 calculated using the "r" method
#'
#' @md
#'
#' @importFrom SNPRelate snpgdsLDMat
#' @importFrom dplyr left_join %>% mutate filter
#' @importFrom tidyr pivot_longer %>%
#' @importFrom tibble tibble %>%


compute_ld <- function(
  gds,
  variant_include_1,
  variant_include_2 = NULL,
  methods = c("composite"),
  sample_include = NULL
) {

  # Checks - to be written.
  # * all sample ids exist.
  # * all variant ids exist.

  # Check that method is allowed

  allowed_methods <- c("composite", "dprime", "corr", "r")
  if (!all(methods %in% allowed_methods)) {
    msg <- sprintf("method is not in set of allowed methods: %s",
                   paste(allowed_methods, collapse = ", "))
    stop(msg)
  }

  variant_include <- unique(c(variant_include_1, variant_include_2))

  res_list <- list()
  for (method in methods) {
    # Calculate ld between all pairs of variants provided.
    ld <- snpgdsLDMat(gds, snp.id = variant_include, sample.id = sample_include, slide = -1, verbose = FALSE, method = method)
    tmp <- ld$LD
    colnames(tmp) <- rownames(tmp) <- ld$snp.id

    dat <- tibble::as_tibble(tmp, rownames="variant.id.1") %>%
      pivot_longer(-variant.id.1, names_to = "variant.id.2", values_to = "ld") %>%
      mutate(variant.id.1 = as.integer(variant.id.1), variant.id.2 = as.integer(variant.id.2))

    # Now filter specific to inputs.
    if (length(variant_include_1 == 1) & length(variant_include_2) == 1) {
      # LD between a pair of variants.
      dat <- dat %>%
        filter(variant.id.1 == variant_include_1, variant.id.2 == variant_include_2)
    } else if (length(variant_include_1 == 1) & length(variant_include_2) > 1) {
        # LD between one variant and a set of other variants.
        dat <- dat %>%
          filter(variant.id.1 == variant_include_1, variant.id.1 != variant.id.2)
    } else if (length(variant_include_1 > 1) & length(variant_include_2) == 0) {
      # LD between all pairs of variants.
      dat <- dat %>%
          filter(variant.id.1 < variant.id.2)
    }

    names(dat)[names(dat) == "ld"] <- sprintf("ld_%s", method)
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
