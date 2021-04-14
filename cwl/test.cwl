cwlVersion: v1.1
class: CommandLineTool
label: test
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.10.0

inputs: []

outputs: []
stdout: job.out.log

baseCommand:
- wget
- https://raw.githubusercontent.com/UW-GAC/ld-compute/sbg-cwl/test_sbg.R
- '&&'
- R
- -q
- --vanilla
arguments:
- prefix: <
  position: 100
  valueFrom: test_sbg.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.log'
id: |-
  https://api.sb.biodatacatalyst.nhlbi.nih.gov/v2/apps/amstilp/ld-compute-devel/test/2/raw/
sbg:appVersion:
- v1.1
sbg:content_hash: afd619bf96e285a12551fc3529a47ada6c2bfdf54a453419ff2ea62f34b7cafee
sbg:contributors:
- amstilp
sbg:createdBy: amstilp
sbg:createdOn: 1618428687
sbg:id: amstilp/ld-compute-devel/test/2
sbg:image_url:
sbg:latestRevision: 2
sbg:modifiedBy: amstilp
sbg:modifiedOn: 1618436277
sbg:project: amstilp/ld-compute-devel
sbg:projectName: LD-compute-devel
sbg:publisher: sbg
sbg:revision: 2
sbg:revisionNotes: fix script name in argument to run test installation script
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
sbg:sbgMaintained: false
sbg:validationErrors: []
