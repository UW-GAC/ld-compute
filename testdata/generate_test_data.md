---
title: Generate test data for ld-compute repository
author: "Adrienne Stilp"
date:  "23 March, 2021"
output:
  html_document:
    toc: true
    toc_depth: 3
    keep_md: true 
---





# Sample include file


```r
set.seed(123)
sample_include <- sample(seqGetData(gds, "sample.id"), 1000)
saveRDS(sample_include, file = "sample_include.rds")
```

# Variant include

Choose some variants that are mono-morphic and some that are not.


```r
seqSetFilter(gds, sample.id=sample_include)
```

```
## # of selected samples: 1,000
```

```r
variant_info <- variantInfo(gds) %>%
  # Add some more info
  mutate(n_alleles = nAlleles(gds),
  af = alleleFrequency(gds),
  maf = pmin(af, 1 - af)
) %>%
  # biallelic only.
  filter(n_alleles == 2)
```

## Pair of variants


```r
set.seed(123)
pair <- variant_info %>%
  filter(maf > 0.2) %>%
  # same chromosome
  filter(chr == 1) %>%
  sample_n(2)
variant_include_1 <- pair$variant.id[1]
variant_include_2 <- pair$variant.id[2]
saveRDS(variant_include_1, "variant_include_pair_1.rds")
saveRDS(variant_include_2, "variant_include_pair_2.rds")
```

## Index variant


```r
set.seed(123)
index_variant <- variant_info %>%
  filter(maf > 0.2) %>%
  sample_n(1)
index_variant
```

```
##   variant.id chr      pos ref alt n_alleles     af    maf
## 1       5836   6 33023946   A   G         2 0.4155 0.4155
```

```r
# Select other variants within 500 kb of this variant
other_variants <- variant_info %>%
  filter(chr == index_variant$chr) %>%
  filter(abs(pos - index_variant$pos) < 500e3)
other_variants
```

```
##    variant.id chr      pos ref alt n_alleles     af    maf
## 1        5829   6 32558827   G   A         2 0.9870 0.0130
## 2        5830   6 32632215   G   T         2 0.9995 0.0005
## 3        5831   6 32724258   C   T         2 0.4990 0.4990
## 4        5832   6 32725826   A   G         2 0.3280 0.3280
## 5        5834   6 32763747   G   C         2 0.9995 0.0005
## 6        5835   6 32797297   T   C         2 0.7250 0.2750
## 7        5836   6 33023946   A   G         2 0.4155 0.4155
## 8        5837   6 33051723   G   T         2 0.5645 0.4355
## 9        5838   6 33064950   C   T         2 0.9440 0.0560
## 10       5839   6 33110036   C   T         2 0.7590 0.2410
```

```r
variant_include_1 <- index_variant$variant.id
variant_include_2 <- other_variants$variant.id
saveRDS(variant_include_1, "variant_include_index_1.rds")
saveRDS(variant_include_2, "variant_include_index_2.rds")
```

## Set of variants

Use the variants that were selected for the "index variant" case.


```r
variant_include <- sort(c(variant_include_1, variant_include_2))
variant_include
```

```
##  [1] 5829 5830 5831 5832 5834 5835 5836 5836 5837 5838 5839
```

```r
saveRDS(variant_include, "variant_include_set_1.rds")
```

# Clean up


```r
seqClose(gds)
```
