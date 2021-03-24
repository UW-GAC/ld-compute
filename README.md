
# README

This repository contains an R package, `LDcompute` to compute LD using
SNPRelate functions and return results in a consistent format. It also
includes an example wrapper script (`compute_ld.R`) and test data
(`testdata/`) to show how it can be used.

## Calling functions directly

Load other packages.

    library(SeqArray)

Load the `LDcompute` package.

Open the gds file:

    gds <- seqOpen("testdata/1KG_phase3_subset.gds")

### LD between a pair of variants

    compute_ld_pair(gds, 1, 2)

    ## # A tibble: 1 x 3
    ##   variant.id.1 variant.id.2 ld_composite
    ##          <int>        <int>        <dbl>
    ## 1            1            2      -0.0286

Using other methods:

    compute_ld_pair(gds, 1, 2, methods = c("composite", "dprime"))

    ## # A tibble: 1 x 4
    ##   variant.id.1 variant.id.2 ld_composite ld_dprime
    ##          <int>        <int>        <dbl>     <dbl>
    ## 1            1            2      -0.0286      1.00

### LD between an index variant and a set of other variants

    compute_ld_index(gds, 1, c(2:10))

    ## # A tibble: 9 x 3
    ##   variant.id.1 variant.id.2 ld_composite
    ##          <int>        <int>        <dbl>
    ## 1            1            2     -0.0286 
    ## 2            1            3     -0.00268
    ## 3            1            4     -0.00379
    ## 4            1            5     -0.0108 
    ## 5            1            6     -0.00599
    ## 6            1            7     -0.00268
    ## 7            1            8     -0.00464
    ## 8            1            9      0.0414 
    ## 9            1           10     -0.0255

Using other methods:

    compute_ld_index(gds, 1, c(2:10), methods = c("composite", "dprime"))

    ## # A tibble: 9 x 4
    ##   variant.id.1 variant.id.2 ld_composite ld_dprime
    ##          <int>        <int>        <dbl>     <dbl>
    ## 1            1            2     -0.0286     1.00  
    ## 2            1            3     -0.00268    1.    
    ## 3            1            4     -0.00379    1.    
    ## 4            1            5     -0.0108     1.00  
    ## 5            1            6     -0.00599    1.    
    ## 6            1            7     -0.00268    1.    
    ## 7            1            8     -0.00464    1.00  
    ## 8            1            9      0.0414     0.0829
    ## 9            1           10     -0.0255     1.

### LD between all pairs in a set of variants

    compute_ld_set(gds, c(1:10))

    ## # A tibble: 45 x 3
    ##    variant.id.1 variant.id.2 ld_composite
    ##           <int>        <int>        <dbl>
    ##  1            1            2     -0.0286 
    ##  2            1            3     -0.00268
    ##  3            1            4     -0.00379
    ##  4            1            5     -0.0108 
    ##  5            1            6     -0.00599
    ##  6            1            7     -0.00268
    ##  7            1            8     -0.00464
    ##  8            1            9      0.0414 
    ##  9            1           10     -0.0255 
    ## 10            2            3     -0.00949
    ## # … with 35 more rows

Using other methods:

    compute_ld_set(gds, c(1:4), methods = c("composite", "dprime"))

    ## # A tibble: 6 x 4
    ##   variant.id.1 variant.id.2 ld_composite ld_dprime
    ##          <int>        <int>        <dbl>     <dbl>
    ## 1            1            2     -0.0286      1.00 
    ## 2            1            3     -0.00268     1.   
    ## 3            1            4     -0.00379     1.   
    ## 4            2            3     -0.00949     1.   
    ## 5            2            4      0.0547      0.446
    ## 6            3            4     -0.00126     1.00

## Cleanup

    seqClose(gds)

## Running compute\_ld.R with test data

### LD between a pair of variants

    R --no-save --args \
      testdata/1KG_phase3_subset.gds \
      --methods composite dprime \
      --variant_include_file_1 testdata/variant_include_pair_1.rds \
      --variant_include_file_2 testdata/variant_include_pair_2.rds \
      --sample_include_file testdata/sample_include.rds \
      --outfile ld_pair.rds \
      < compute_ld.R

### LD between an index variant and a set of other variants

    R --no-save --args \
      testdata/1KG_phase3_subset.gds \
      --methods composite dprime \
      --variant_include_file_1 testdata/variant_include_index_1.rds \
      --variant_include_file_2 testdata/variant_include_index_2.rds \
      --sample_include_file testdata/sample_include.rds \
      --outfile ld_index.rds \
      < compute_ld.R

### LD between all pairs in a set of variants

    R --no-save --args \
      testdata/1KG_phase3_subset.gds \
      --methods composite dprime \
      --variant_include_file_1 testdata/variant_include_set_1.rds \
      --sample_include_file testdata/sample_include.rds \
      --outfile ld_set.rds \
      < compute_ld.R
