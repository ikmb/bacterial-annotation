# Usage information

This pipeline is configured to run on the IKMB medCluster. More generel support for other compute systems may follow later. 

## Basic example

```
nextflow run ikmb/bacterial-annotation --assemblies '/path/to/assemblies/*.fasta'
```

## Options

### `--assemblies`

A regular expression pointing to a list of bacterial assemblies in FASTA format. 

### `--tools prokka,dfast`

This pipeline currently supports to annotation tools:

- [DFast_core](https://github.com/nigyta/dfast_core) [dfast]
- [Prokka](https://github.com/tseemann/prokka) [prokka]

Specify one or both tools - sperated by comma; results will be stored in the respective subfolder. 

### `--outdir` [default = "results" ]

The directory where to store the results. 



