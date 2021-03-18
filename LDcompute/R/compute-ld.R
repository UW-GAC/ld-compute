compute_ld <- function(gds, variant_include_1, variant_include_2 = NULL, methods = c("composite")) {

  # Checks - to be written.

  # Check that method is allowed

  allowed_methods <- c("composite", "dprime", "corr", "r")
  if (!all(methods %in% allowed_methods)) {
    msg <- sprintf("method is not in set of allowed methods: %s",
                   paste(allowed_methods, collapse = ", "))
    stop(msg)
  }

  # Choose which method to call - to be written.

  res_list <- list()
  for (method in methods) {
  # Compute LD for a pair of variants.
    res_list[[method]] <- .compute_ld_one_to_one(gds, variant_include_1, variant_include_2, method = method)
  }

  # Add other methods to the data frame as columns.
  # This is probably slow.
  res <- res_list[[1]]
  if (length(methods) > 1) {
    for (i in 2:length(methods)) {
      res <- res %>%
        dplyr::left_join(res_list[[i]], by = c("variant.id.1", "variant.id.2"))
    }
  }
  res
}

# Computes LD between a pair of variants.
.compute_ld_one_to_one <- function(gds, variant_include_1, variant_include_2, method) {

  # For variant.ids with multiple alternate alleles, I think that snpgdsLDMat
  # just uses the ref dosage to calculate LD.
  ld <- snpgdsLDMat(gds, snp.id = c(variant_include_1, variant_include_2),
                    method = method, slide = -1, verbose = FALSE)

  dat <- tibble::tibble(
    variant.id.1 = variant_include_1,
    variant.id.2 = variant_include_2,
    ld = ld$LD[1,2]
  )
  names(dat)[names(dat) == "ld"] <- sprintf("ld_%s", method)
  dat
}

# Computes LD between one variant and a set of other variants.
.compute_ld_one_to_many <- function() {}

# Computes LD between all pairs of a set of variants.
.compute_ld_many_to_many <- function() {}
