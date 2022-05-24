cwlVersion: v1.1
class: CommandLineTool
label: ld-index
doc: |-
  Linkage disequilibrium (LD) is a measure of the non-random association of alleles at different loci in a given sample set. It is often used in genetic data analysis to identify a set of independent variants, to identify independent signals in association test results, or to examine the correlation between two variants in a dataset.

  This tool calculates the LD among an index variant and each variant in a set of other variants stored in a GDS file using the `snpgdsLDMat` function in the [SNPRelate R package](https://bioconductor.org/packages/release/bioc/html/SNPRelate.html) and a wrapper [LDcompute R package](https://github.com/UW-GAC/ld-compute). Users can optionally specify the set of samples to use in the calculation. Genotypes must first be converted to [SeqArray](https://bioconductor.org/packages/release/bioc/html/SeqArray.html) GDS format to use this tool.

  The user can choose three different methods to calculate LD:

  * `r`: the pearson correlation coefficient between the reference allele dosages for the pair of variants.
  * `r2`: the squared pearson correlation coefficient between the reference allele dosages for the pair of variants.
  * `dprime`: the normalized coefficient of linkage disequilibrium, which measures the difference of the frequency at which a pair of alleles at the two variants are observed together from the expected frequency if the two variants were independent.

  Multiple LD calculation methods can be selected in one run.

  The tool produces an RDS file containing a tibble with multiple rows with the following columns:

  column | description
  --- | ---
  `variant.id.1` | the variant.id of the index variant
  `variant.id.2` | the other variant.id
  `ld_r` | (if LD method includes `r`) the LD value for `variant.id.1` and `variant.id.2` calculated using the `r` method
  `ld_r2` | (if LD method includes `r2`) the LD value for `variant.id.1` and `variant.id.2` calculated using the `r2` method
  `ld_dprime` | (if LD method includes `dprime`) the LD value for these two variants calculated using the `dprime` method

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.10.0
- class: InitialWorkDirRequirement
  listing:
  - entryname: install_package.R
    writable: false
    entry: |-
      remotes::install_github('UW-GAC/ld-compute', subdir='LDcompute', dependencies = FALSE)
- class: InlineJavascriptRequirement

inputs:
- id: gds_file
  type: File
  inputBinding:
    position: 0
    shellQuote: false
  label: GDS file
  doc: GDS file
- id: ld_methods
  type:
    type: array
    items:
      type: enum
      name: ld_methods
      symbols:
        - r2
        - r
        - dprime
  inputBinding:
    prefix: --ld_methods
    position: 1
    shellQuote: false
  label: LD calculation method
  doc: Methods to use for calculating LD. Can be one of r2, dprime, r.
- id: index_variant_include_file
  type: File
  inputBinding:
    prefix: --variant_include_file_1
    position: 2
    shellQuote: false
  label: Index variant file
  doc: File containing variant id of the index variant.
- id: other_variant_include_file
  type: File
  inputBinding:
    prefix: --variant_include_file_2
    position: 3
    shellQuote: false
  label: Other variant id file
  doc: File containing variant ids of the other variants to calculate LD with index variant.
- id: output_prefix
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 4
    shellQuote: false
  label: Output file prefix.
  doc: Output file prefix. Will be appended to "_ld.rds".
- id: sample_include_file
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 5
    shellQuote: false
  label: Sample include file
  doc: File containing the sample ids on which to calculate LD.
- id: cpu
  label: cpu
  doc: Number of CPUs to use.
  type: int?
  default: 4
  inputBinding:
    prefix: --n_threads
    position: 20
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '4'

outputs:
- id: ld
  type: File?
  outputBinding:
    glob: '*.rds'
stdout: job.out.log

baseCommand:
- R -q --vanilla < install_package.R
- '&&'
- wget https://raw.githubusercontent.com/UW-GAC/ld-compute/main/compute_ld.R
- '&&'
- R -q --vanilla --args
arguments:
- prefix: <
  position: 100
  valueFrom: compute_ld.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.log'
