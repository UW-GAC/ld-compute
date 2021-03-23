# Calculate LD for a set of variants
sessionInfo()
.libPaths()

library(argparser)
library(magrittr)
library(SeqArray)
library(LDcompute)

argp <- arg_parser("Calculate LD") %>%
  add_argument("gds", help = "path to the GDS file") %>%
  add_argument("--methods", nargs = Inf, help = "method for computing LD") %>%
  add_argument("--variant_include_file_1", help = "path to a file containing variant ids") %>%
  add_argument("--variant_include_file_2", help = "path to a file containing variant ids (optional)") %>%
  add_argument("--sample_include_file", help = "path to a file containing the set of sample ids to include") %>%
  add_argument("--outfile", help = "output file name")

argv <- parse_args(argp)
print(argv)

# Variant include
if (!is.na(argv$variant_include_file_1)) {
  variant_include_1 <- readRDS(argv$variant_include_file_1)
} else {
  stop("variant_include_file_1 must be specified.")
}
if (!is.na(argv$variant_include_file_2)) {
  variant_include_2 <- readRDS(argv$variant_include_file_2)
} else {
  variant_include_2 <- NULL
}

# Decide which LD function to call.
if (length(variant_include_1) == 1 & length(variant_include_2) == 1) {
  ld_type <- "pair"
} else if (length(variant_include_1) == 1 & length(variant_include_2) > 0) {
  ld_type <- "index"
} else if (length(variant_include_1) > 1 & length(variant_include_2) == 0) {
  ld_type <- "set"
} else {
  stop("Check variant_include inputs.")
}
ld_type

# Sample include.
if (!is.na(argv$sample_include_file)) {
  sample_include <- readRDS(argv$sample_include_file)
} else {
  sample_include <- NULL
}

gds <- seqOpen(argv$gds)

if (ld_type == "pair") {
  ld <- compute_ld_pair(gds, variant_include_1, variant_include_2, sample_include = sample_include, methods = argv$methods)
} else if (ld_type == "index") {
  ld <- compute_ld_index(gds, variant_include_1, variant_include_2, sample_include = sample_include, methods = argv$methods)
} else if (ld_type == "set") {
  ld <- compute_ld_set(gds, variant_include_1, sample_include = sample_include, methods = argv$methods)
}

# Preview.
## Change to head(ld) once testing is done.
ld

# Save
saveRDS(ld, file = argv$outfile)
