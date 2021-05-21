cwlVersion: v1.1
class: CommandLineTool
label: ld-pair
doc: |-
  Calculate LD between a pair of variants.

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
- id: variant_include_file_1
  type: File
  inputBinding:
    prefix: --variant_include_file_1
    position: 2
    shellQuote: false
  label: Variant id file 1
  doc: File containing first variant id in the pair.
- id: variant_include_file_2
  type: File?
  inputBinding:
    prefix: --variant_include_file_2
    position: 3
    shellQuote: false
  label: Variant id file 2
  doc: File containing second variant id in the pair.
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
