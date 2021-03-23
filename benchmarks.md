---
title: Time and memory benchmarks for LD calculation code
author: "Adrienne Stilp"
date:  "23 March, 2021"
output:
  html_document:
    toc: true
    toc_depth: 3
    keep_md: true
---






# GDS prep


```r
gds <- seqOpen("testdata/1KG_phase3_subset.gds")
variant_info <- variantInfo(gds) %>%
  mutate(
    n_alleles = nAlleles(gds),
    af = alleleFrequency(gds),
    maf = pmin(af, 1 - af)
  ) %>%
  filter(n_alleles == 2, maf > 0.1)
sample_ids <- seqGetData(gds, "sample.id")
```

# Pair of variants


```r
set.seed(123)
variant_pair <- variant_info %>%
  sample_n(2)
variant_pair
```

```
##   variant.id chr      pos   ref alt n_alleles        af       maf
## 1      21442  20  9582938 AAAAT   A         2 0.2175844 0.2175844
## 2      21836  20 31627592     C   A         2 0.4729130 0.4729130
```

```r
var1 <- variant_pair$variant.id[1]
var2 <- variant_pair$variant.id[2]
```

## Sample size


```r
set.seed(123)

bm <- microbenchmark(
  "10" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:10]),
  "50" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:50]),
  "100" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:100]),
  "500" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:500]),
  "1000" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000]),
  unit=UNIT
)
bm_dat <- tibble(
  n_samples = as.integer(as.character(bm$expr)),
  time = bm$time / 1e9 # reported in nanoseconds by microbenchmark
)
ggplot(bm_dat, aes(x = n_samples, y = time, group = n_samples)) +
  geom_boxplot()  +
  stat_summary(fun = "median", color = "red")
```

```
## Warning: Removed 5 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |      min|       lq|     mean|   median|       uq|      max| neval|
|:----|--------:|--------:|--------:|--------:|--------:|--------:|-----:|
|10   | 9.796232| 9.832776| 10.43251| 9.895214| 10.08792| 14.46743|   100|
|50   | 9.792343| 9.830352| 10.53970| 9.873261| 10.08080| 24.64018|   100|
|100  | 9.798199| 9.847103| 11.42042| 9.949786| 10.10327| 46.69757|   100|
|500  | 9.828184| 9.866934| 10.78646| 9.910264| 10.12513| 26.92271|   100|
|1000 | 9.843050| 9.876798| 10.79963| 9.948108| 10.24002| 18.76662|   100|

## Number of variants

Irrelevant for `compute_ld_pair`.

## Method types


```r
bm <- microbenchmark(
  "composite" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], methods = "composite"),
  "dprime" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], methods = "dprime"),
  "corr" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], methods = "corr"),
  "r" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], methods = "r"),
  unit=UNIT
)
bm_dat <- tibble(
  method = as.character(bm$expr),
  time = bm$time / 1e9 # reported in nanoseconds by microbenchmark
)
ggplot(bm_dat, aes(x = method, y = time, group = method)) +
  geom_boxplot()  +
  stat_summary(fun = "median", color = "red")
```

```
## Warning: Removed 4 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr      |      min|       lq|     mean|    median|       uq|      max| neval|
|:---------|--------:|--------:|--------:|---------:|--------:|--------:|-----:|
|composite | 9.812066| 9.843392| 10.01725| 10.011476| 10.09040| 10.80986|   100|
|dprime    | 9.812013| 9.841397| 10.06821|  9.964109| 10.14499| 13.22644|   100|
|corr      | 9.807007| 9.838345| 10.20306|  9.973077| 10.14691| 22.99572|   100|
|r         | 9.811377| 9.843305| 10.11210| 10.023204| 10.13406| 14.71517|   100|

## Number of methods


```r
set.seed(123)
sample_ids <- seqGetData(gds, "sample.id")[1:1000]

bm <- microbenchmark(
  "1" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], methods = "composite"),
  "2" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], methods = c("composite", "dprime")),
  "3" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], methods = c("composite", "dprime", "corr")),
  "4" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], methods = c("composite", "dprime", "corr", "r")),
  unit=UNIT
)
bm_dat <- tibble(
  n_methods = as.integer(as.character(bm$expr)),
  time = bm$time / 1e9 # reported in nanoseconds by microbenchmark
)
ggplot(bm_dat, aes(x = n_methods, y = time, group = n_methods)) +
  geom_boxplot()  +
  stat_summary(fun = "median", color = "red")
```

```
## Warning: Removed 4 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |      min|       lq|     mean|   median|       uq|      max| neval|
|:----|--------:|--------:|--------:|--------:|--------:|--------:|-----:|
|1    | 10.10248| 10.12471| 10.42681| 10.13821| 10.16095| 23.54975|   100|
|2    | 18.15694| 18.20163| 18.72585| 18.23004| 18.30729| 37.36471|   100|
|3    | 26.17775| 26.22734| 26.46249| 26.26862| 26.43961| 29.49997|   100|
|4    | 34.16300| 34.23483| 34.98618| 34.28213| 34.46125| 44.33468|   100|

# Index variant


```r
index_variant <- variant_info %>%
  slice(1) %>%
  pull(variant.id)
index_variant
```

```
## [1] 16
```


## Sample size


```r
other_variant_ids <- variant_info$variant.id[2:1001]
bm <- microbenchmark(
  "10" = compute_ld_index(gds, index_variant, other_variant_ids, sample_include = sample_ids[1:10]),
  "50" = compute_ld_index(gds, index_variant, other_variant_ids, sample_include = sample_ids[1:50]),
  "100" = compute_ld_index(gds, index_variant, other_variant_ids, sample_include = sample_ids[1:100]),
  "500" = compute_ld_index(gds, index_variant, other_variant_ids, sample_include = sample_ids[1:500]),
  "1000" = compute_ld_index(gds, index_variant, other_variant_ids, sample_include = sample_ids[1:1000]),
  unit=UNIT
)
bm_dat <- tibble(
  n_samples = as.integer(as.character(bm$expr)),
  time = bm$time / 1e9 # reported in nanoseconds by microbenchmark
)
ggplot(bm_dat, aes(x = n_samples, y = time, group = n_samples)) +
  geom_boxplot()  +
  stat_summary(fun = "median", color = "red")
```

```
## Warning: Removed 5 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |       min|        lq|      mean|    median|        uq|       max| neval|
|:----|---------:|---------:|---------:|---------:|---------:|---------:|-----:|
|10   |  114.6886|  119.9305|  158.0601|  124.0277|  134.4874|  617.7881|   100|
|50   |  153.3306|  158.5796|  200.5213|  160.9455|  167.9288|  804.0679|   100|
|100  |  203.6320|  208.6549|  245.6409|  211.2100|  220.3207|  835.2407|   100|
|500  |  615.8889|  620.8656|  651.0464|  623.1024|  631.0974| 1051.9573|   100|
|1000 | 1126.8145| 1131.7564| 1167.3301| 1134.0777| 1147.3631| 1737.5211|   100|

## Number of variants


```r
bm <- microbenchmark(
  "10" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:11], sample_include = sample_ids[1:1000]),
  "50" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:51], sample_include = sample_ids[1:1000]),
  "100" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:101], sample_include = sample_ids[1:1000]),
  "500" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:501], sample_include = sample_ids[1:1000]),
  "1000" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:1001], sample_include = sample_ids[1:1000]),
  unit=UNIT
)
bm_dat <- tibble(
  n_variants = as.integer(as.character(bm$expr)),
  time = bm$time / 1e9 # reported in nanoseconds by microbenchmark
)
ggplot(bm_dat, aes(x = n_variants, y = time, group = n_variants)) +
  geom_boxplot()  +
  stat_summary(fun = "median", color = "red")
```

```
## Warning: Removed 5 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |        min|          lq|        mean|      median|          uq|        max| neval|
|:----|----------:|-----------:|-----------:|-----------:|-----------:|----------:|-----:|
|10   |    7.88878|    8.003068|    8.363269|    8.186149|    8.463468|   13.79620|   100|
|50   |   12.40109|   12.497355|   13.089845|   12.719454|   13.263302|   32.07197|   100|
|100  |   22.44133|   22.593011|   23.029665|   22.809753|   23.300299|   27.54963|   100|
|500  |  297.13293|  297.446166|  303.481646|  297.933074|  302.397040|  651.92159|   100|
|1000 | 1125.80771| 1129.577305| 1152.749353| 1132.789078| 1138.805715| 1622.19789|   100|

# Set of variants


## Sample size


```r
variant_include <- variant_info$variant.id[1:1000]
bm <- microbenchmark(
  "10" = compute_ld_set(gds, variant_include, sample_include = sample_ids[1:10]),
  "50" = compute_ld_set(gds, variant_include, sample_include = sample_ids[1:50]),
  "100" = compute_ld_set(gds, variant_include, sample_include = sample_ids[1:100]),
  "500" = compute_ld_set(gds, variant_include, sample_include = sample_ids[1:500]),
  "1000" = compute_ld_set(gds, variant_include, sample_include = sample_ids[1:1000]),
  unit=UNIT
)
bm_dat <- tibble(
  n_samples = as.integer(as.character(bm$expr)),
  time = bm$time / 1e9 # reported in nanoseconds by microbenchmark
)
ggplot(bm_dat, aes(x = n_samples, y = time, group = n_samples)) +
  geom_boxplot()  +
  stat_summary(fun = "median", color = "red")
```

```
## Warning: Removed 5 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |       min|        lq|      mean|    median|        uq|       max| neval|
|:----|---------:|---------:|---------:|---------:|---------:|---------:|-----:|
|10   |  104.1840|  104.7051|  126.9031|  109.4652|  114.6185|  541.6628|   100|
|50   |  143.8221|  144.3135|  154.6649|  148.9978|  151.3449|  542.2774|   100|
|100  |  193.5105|  198.1668|  224.3762|  198.7425|  205.9002|  614.7124|   100|
|500  |  605.2735|  605.9170|  612.1582|  610.5005|  613.6306|  645.1558|   100|
|1000 | 1115.1398| 1119.6467| 1135.5108| 1120.7930| 1128.4079| 1547.3402|   100|

## Number of variants


```r
set.seed(123)
sample_ids <- seqGetData(gds, "sample.id")[1:1000]

bm <- microbenchmark(
  "10" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:10], sample_include = sample_ids[1:1000]),
  "50" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:50], sample_include = sample_ids[1:1000]),
  "100" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:100], sample_include = sample_ids[1:1000]),
  "500" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:500], sample_include = sample_ids[1:1000]),
  "1000" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:1000], sample_include = sample_ids[1:1000]),
  unit=UNIT
)
bm_dat <- tibble(
  n_variants = as.integer(as.character(bm$expr)),
  time = bm$time / 1e9 # reported in nanoseconds by microbenchmark
)
ggplot(bm_dat, aes(x = n_variants, y = time, group = n_variants)) +
  geom_boxplot()  +
  stat_summary(fun = "median", color = "red")
```

```
## Warning: Removed 5 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |         min|          lq|        mean|      median|          uq|        max| neval|
|:----|-----------:|-----------:|-----------:|-----------:|-----------:|----------:|-----:|
|10   |    7.844858|    7.997434|    8.679132|    8.188698|    8.782078|   26.52634|   100|
|50   |   12.175595|   12.332527|   12.623446|   12.505097|   12.807135|   15.97201|   100|
|100  |   22.220871|   22.342522|   22.893993|   22.587685|   22.946949|   35.64222|   100|
|500  |  295.982348|  296.418730|  302.872019|  297.147205|  301.271981|  714.80352|   100|
|1000 | 1124.329319| 1128.312332| 1149.587783| 1130.146229| 1138.209907| 1599.25296|   100|

# Cleanup


```r
seqClose(gds)
```
