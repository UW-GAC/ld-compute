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
- id: ld_methods
  type: string
  inputBinding:
    prefix: --ld_methods
    position: 1
    shellQuote: false
- id: variant_include_file_1
  type: File
  inputBinding:
    prefix: --variant_include_file_1
    position: 2
    shellQuote: false
- id: variant_include_file_2
  type: File?
  inputBinding:
    prefix: --variant_include_file_2
    position: 3
    shellQuote: false
- id: outfile
  type: string
  inputBinding:
    prefix: --outfile
    position: 4
    shellQuote: false

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
id: |-
  https://api.sb.biodatacatalyst.nhlbi.nih.gov/v2/apps/amstilp/ld-compute-devel/test/17/raw/
sbg:appVersion:
- v1.1
sbg:content_hash: a07bae9358b5e2f73bf8858d17f9a92dfc705fc42853bb4a5333e7fffa0a6e5ba
sbg:contributors:
- amstilp
sbg:createdBy: amstilp
sbg:createdOn: 1618428687
sbg:id: amstilp/ld-compute-devel/test/17
sbg:image_url:
sbg:latestRevision: 17
sbg:modifiedBy: amstilp
sbg:modifiedOn: 1618521618
sbg:project: amstilp/ld-compute-devel
sbg:projectName: LD-compute-devel
sbg:publisher: sbg
sbg:revision: 17
sbg:revisionNotes: specify prefix instead of value transform for variant_include_file_2
sbg:revisionsInfo:
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618428687
  sbg:revision: 0
  sbg:revisionNotes:
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618435599
  sbg:revision: 1
  sbg:revisionNotes: initial version
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618436277
  sbg:revision: 2
  sbg:revisionNotes: fix script name in argument to run test installation script
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618440621
  sbg:revision: 3
  sbg:revisionNotes: |-
    Uploaded using sbpack v2020.10.05. 
    Source: 
    repo: git@github.com:UW-GAC/ld-compute.git
    file: cwl/test.cwl
    commit: 59012e7
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618441664
  sbg:revision: 4
  sbg:revisionNotes: |-
    Uploaded using sbpack v2020.10.05. 
    Source: 
    repo: git@github.com:UW-GAC/ld-compute.git
    file: cwl/test.cwl
    commit: (uncommitted file)
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618503335
  sbg:revision: 5
  sbg:revisionNotes: Try installing LD compute package using a file requirement file
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618504227
  sbg:revision: 6
  sbg:revisionNotes: file rqeuirement script name
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618504713
  sbg:revision: 7
  sbg:revisionNotes: typo in baseCommand file name
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618505080
  sbg:revision: 8
  sbg:revisionNotes: try reordering base commands
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618507703
  sbg:revision: 9
  sbg:revisionNotes: remove quotes around &&
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618509005
  sbg:revision: 10
  sbg:revisionNotes: do not split base commands by spaces
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618509160
  sbg:revision: 11
  sbg:revisionNotes: try running both setup commands in a shell script
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618510753
  sbg:revision: 12
  sbg:revisionNotes: revert to revision 10
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618511264
  sbg:revision: 13
  sbg:revisionNotes: wget and run compute_ld.R script (this will fail)
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618514636
  sbg:revision: 14
  sbg:revisionNotes: Add input and output ports
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618514978
  sbg:revision: 15
  sbg:revisionNotes: Add --args flag to R call
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618515682
  sbg:revision: 16
  sbg:revisionNotes: add --outfile prefix to outfile
- sbg:modifiedBy: amstilp
  sbg:modifiedOn: 1618521618
  sbg:revision: 17
  sbg:revisionNotes: specify prefix instead of value transform for variant_include_file_2
sbg:sbgMaintained: false
sbg:validationErrors: []
