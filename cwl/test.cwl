cwlVersion: v1.1
class: CommandLineTool
label: test
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.10.0
- class: InlineJavascriptRequirement

inputs: []

outputs: []
stdout: job.out.log

baseCommand:
- wget https://raw.githubusercontent.com/UW-GAC/ld-compute/sbg-cwl/test_sbg.R '&&'
- R -q --vanilla
arguments:
- prefix: <
  position: 100
  valueFrom: test_sbg.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.log'
id: |-
  https://api.sb.biodatacatalyst.nhlbi.nih.gov/v2/apps/amstilp/ld-compute-devel/test/3/raw/
sbg:appVersion:
- v1.1
sbg:content_hash: a46eb4a1a863904c1e6b2a6a6907c1085754d61487e78f48dc047d529d19dca86
sbg:contributors:
- amstilp
sbg:createdBy: amstilp
sbg:createdOn: 1618428687
sbg:id: amstilp/ld-compute-devel/test/3
sbg:image_url:
sbg:latestRevision: 3
sbg:modifiedBy: amstilp
sbg:modifiedOn: 1618440621
sbg:project: amstilp/ld-compute-devel
sbg:projectName: LD-compute-devel
sbg:publisher: sbg
sbg:revision: 3
sbg:revisionNotes: |-
  Uploaded using sbpack v2020.10.05. 
  Source: 
  repo: git@github.com:UW-GAC/ld-compute.git
  file: cwl/test.cwl
  commit: 59012e7
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
sbg:sbgMaintained: false
sbg:validationErrors: []
