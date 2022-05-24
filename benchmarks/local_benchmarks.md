---
title: Time and memory benchmarks for LD calculation code
author: "Adrienne Stilp"
date:  "25 March, 2021"
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
|10   | 10.52532| 10.61405| 10.66807| 10.65764| 10.71359| 11.01763|   100|
|50   | 10.53113| 10.59380| 10.69426| 10.65833| 10.73153| 11.83102|   100|
|100  | 10.52383| 10.56888| 10.71255| 10.65779| 10.69809| 16.13594|   100|
|500  | 10.53181| 10.57622| 10.74280| 10.68145| 10.71668| 16.57766|   100|
|1000 | 10.56252| 10.60779| 10.75292| 10.69983| 10.75587| 13.24533|   100|

## Number of variants

Irrelevant for `compute_ld_pair`.

## Method types


```r
bm <- microbenchmark(
  "dprime" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], ld_methods ="dprime"),
  "corr" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], ld_methods ="r2"),
  "r" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], ld_methods ="r"),
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
## Warning: Removed 3 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr   |      min|       lq|     mean|   median|       uq|      max| neval|
|:------|--------:|--------:|--------:|--------:|--------:|--------:|-----:|
|dprime | 10.47735| 10.51143| 10.58766| 10.52883| 10.59122| 11.72213|   100|
|corr   | 10.56873| 10.59413| 10.74529| 10.61461| 10.68337| 16.14324|   100|
|r      | 10.47711| 10.50188| 10.64563| 10.52788| 10.63914| 11.72040|   100|

## Number of methods


```r
set.seed(123)
sample_ids <- seqGetData(gds, "sample.id")[1:1000]

bm <- microbenchmark(
  "1" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], ld_methods ="r2"),
  "2" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], ld_methods =c("r2", "r")),
  "3" = compute_ld_pair(gds, var1, var2, sample_include = sample_ids[1:1000], ld_methods =c("r2", "r", "dprime")),
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
## Warning: Removed 3 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |      min|       lq|     mean|   median|       uq|      max| neval|
|:----|--------:|--------:|--------:|--------:|--------:|--------:|-----:|
|1    | 10.57610| 10.70303| 11.02043| 10.76707| 10.87955| 16.67697|   100|
|2    | 18.89311| 19.11280| 19.55535| 19.20557| 19.52561| 25.20497|   100|
|3    | 27.15608| 27.49262| 28.17799| 27.65991| 27.90577| 36.07658|   100|

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



|expr |      min|       lq|     mean|   median|       uq|       max| neval|
|:----|--------:|--------:|--------:|--------:|--------:|---------:|-----:|
|10   | 110.4157| 114.9221| 138.9031| 119.6042| 129.0897|  562.7005|   100|
|50   | 125.2014| 129.1855| 139.5342| 130.8269| 137.3624|  648.7987|   100|
|100  | 141.4134| 146.1762| 166.1708| 150.8383| 161.5544|  644.6663|   100|
|500  | 283.8662| 289.4239| 312.0171| 295.0945| 302.5886|  722.0050|   100|
|1000 | 459.3947| 466.8479| 499.5879| 477.3993| 492.8293| 1046.3241|   100|

## Number of variants


```r
bm <- microbenchmark(
  "10" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:11], sample_include = sample_ids[1:1000]),
  "50" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:51], sample_include = sample_ids[1:1000]),
  "100" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:101], sample_include = sample_ids[1:1000]),
  "500" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:501], sample_include = sample_ids[1:1000]),
  "1000" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:1001], sample_include = sample_ids[1:1000]),
  "2000" = compute_ld_index(gds, index_variant, variant_info$variant.id[2:2001], sample_include = sample_ids[1:1000]),
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
## Warning: Removed 6 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |         min|         lq|        mean|      median|         uq|        max| neval|
|:----|-----------:|----------:|-----------:|-----------:|----------:|----------:|-----:|
|10   |    8.388838|    8.77740|    9.657953|    9.411273|   10.09247|   13.63362|   100|
|50   |   11.361909|   11.85990|   12.549716|   12.326756|   12.86233|   16.23072|   100|
|100  |   16.426368|   17.08628|   18.114068|   17.562661|   18.29774|   32.72102|   100|
|500  |  131.347823|  132.47957|  149.122407|  135.221907|  140.60918|  679.80625|   100|
|1000 |  459.478373|  467.96650|  515.247383|  477.189912|  503.31020| 1044.14439|   100|
|2000 | 1745.609591| 1860.51614| 2135.320850| 2199.128644| 2308.69160| 2754.57724|   100|

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



|expr |       min|       lq|     mean|   median|       uq|      max| neval|
|:----|---------:|--------:|--------:|--------:|--------:|--------:|-----:|
|10   |  99.00866| 101.4256| 118.4057| 105.9747| 111.4181| 639.7390|   100|
|50   | 114.26350| 115.1583| 127.4614| 119.8944| 128.1285| 603.7246|   100|
|100  | 130.87990| 131.8685| 156.8707| 136.6305| 142.4315| 660.6176|   100|
|500  | 272.77804| 277.4445| 295.7624| 281.7978| 292.4052| 753.8523|   100|
|1000 | 448.99267| 453.6685| 472.3224| 459.9931| 481.4683| 874.1749|   100|

## Number of variants


```r
set.seed(123)

bm <- microbenchmark(
  "10" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:10], sample_include = sample_ids[1:1000]),
  "50" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:50], sample_include = sample_ids[1:1000]),
  "100" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:100], sample_include = sample_ids[1:1000]),
  "500" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:500], sample_include = sample_ids[1:1000]),
  "1000" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:1000], sample_include = sample_ids[1:1000]),
  "2000" = compute_ld_index(gds, index_variant, variant_info$variant.id[1:2000], sample_include = sample_ids[1:1000]),
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
## Warning: Removed 6 rows containing missing values (geom_segment).
```

![](benchmarks_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

```r
summary(bm) %>%
  kable()
```



|expr |         min|          lq|        mean|     median|         uq|        max| neval|
|:----|-----------:|-----------:|-----------:|----------:|----------:|----------:|-----:|
|10   |    8.367458|    8.780274|    9.304719|    9.19499|    9.49988|   14.23363|   100|
|50   |   11.184383|   11.607853|   12.313405|   11.98148|   12.40251|   18.31356|   100|
|100  |   16.415881|   16.818565|   21.479383|   17.36042|   17.76981|  407.86593|   100|
|500  |  130.968224|  132.013240|  136.558505|  133.73525|  136.61674|  210.40399|   100|
|1000 |  459.052378|  462.110669|  479.279536|  468.05104|  477.94144|  849.21447|   100|
|2000 | 1731.391091| 1922.909789| 2102.688719| 2154.35679| 2219.06152| 2541.41869|   100|

# Cleanup


```r
seqClose(gds)
```
