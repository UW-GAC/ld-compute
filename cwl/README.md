# Deployment

To deploy the apps on SBG, push them to the correct project.

## Devel project

Push to the devel project to test the app before release.

```
sbpack bdc amstilp/ld-compute-devel/ld-index cwl/ld-index.cwl
sbpack bdc amstilp/ld-compute-devel/ld-pair cwl/ld-pair.cwl
sbpack bdc amstilp/ld-compute-devel/ld-set cwl/ld-set.cwl
```

## Commit project

Push to the commit project to make a new release.

```
sbpack bdc smgogarten/uw-gac-commit/ld-index cwl/ld-index.cwl
sbpack bdc smgogarten/uw-gac-commit/ld-pair cwl/ld-pair.cwl
sbpack bdc smgogarten/uw-gac-commit/ld-set cwl/ld-set.cwl
```
