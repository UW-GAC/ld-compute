cwlVersion: v1.1
class: CommandLineTool
label: test
$namespaces:
  sbg: https://sevenbridges.com

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
  type: string
  inputBinding:
    prefix: --ld_methods
    position: 1
    shellQuote: false
  label: LD calculation method
  doc: Methods to use for calculating LD. Can be one of: r2, dprime, r.
- id: variant_include_file_1
  type: File
  inputBinding:
    prefix: --variant_include_file_1
    position: 2
    shellQuote: false
  label: Variant id file
  doc: File containing variant ids.
- id: variant_include_file_2
  type: File?
  inputBinding:
    prefix: --variant_include_file_2
    position: 3
    shellQuote: false
  label: Variant id file
  doc: File containing variant ids.
- id: outfile
  type: string
  inputBinding:
    prefix: --outfile
    position: 4
    shellQuote: false
  label: Output file.
  doc: Output file. Must end in .rds.

outputs:
- id: ld
  type: File?
  outputBinding:
    glob: '*.rds'
stdout: job.out.log

baseCommand:
- R -q --vanilla < install_package.R
- '&&'
- wget https://raw.githubusercontent.com/UW-GAC/ld-compute/sbg-cwl/compute_ld.R
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
