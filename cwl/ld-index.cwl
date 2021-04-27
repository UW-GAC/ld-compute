cwlVersion: v1.1
class: CommandLineTool
label: ld-index
doc: Calculate LD between an index variant and a set of other variants.

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
    name: ld_methods
    type: enum
    symbols:
    - r2
    - dprime
    - r
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
  label: Index variant file
  doc: File containing variant id of the index variant.
- id: variant_include_file_2
  type: File?
  inputBinding:
    prefix: --variant_include_file_2
    position: 3
    shellQuote: false
  label: Other variant id file
  doc: File containing variant ids of the other variants to calculate LD with index variant.
- id: outfile
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 4
    shellQuote: false
  label: Output file prefix.
  doc: Output file prefix. Will be appended to "_ld.rds".

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
