# Calculate LD for a set of variants

library(argparser)
library(magrittr)

argp <- argparser("Calculate LD") %>%
  add_argument("--gds", help = "path to the GDS file") %>%
  add_argument("--method", help = "method for computing LD") %>%
  add_argument("--variant_include_1_file", help = "path to a file containing variant ids") %>%
  add_argument("--variant_include_2_file", help = "path to a file containing variant ids") %>%
  add_argument("--sample-include-file", help = "path to a file containing the set of sample ids to include") %>%
  add_argument("--outfile", help = "output filename that will be generated")
