# README

Skeleton README for ld-compute repository.

## Running compute_ld.R with test data

### LD between a pair of variants

```
R --no-save --args \
  testdata/1KG_phase3_subset.gds \
  --methods composite dprime \
  --variant_include_file_1 testdata/variant_include_pair_1.rds \
  --variant_include_file_2 testdata/variant_include_pair_2.rds \
  --sample_include_file testdata/sample_include.rds \
  --outfile ld_pair.rds \
  < compute_ld.R
```

### LD between an index variant and a set of other variants

```
R --no-save --args \
  testdata/1KG_phase3_subset.gds \
  --methods composite dprime \
  --variant_include_file_1 testdata/variant_include_index_1.rds \
  --variant_include_file_2 testdata/variant_include_index_2.rds \
  --sample_include_file testdata/sample_include.rds \
  --outfile ld_index.rds \
  < compute_ld.R
```

### LD between all pairs in a set of variants

```
R --no-save --args \
  testdata/1KG_phase3_subset.gds \
  --methods composite dprime \
  --variant_include_file_1 testdata/variant_include_set_1.rds \
  --sample_include_file testdata/sample_include.rds \
  --outfile ld_set.rds \
  < compute_ld.R
```
