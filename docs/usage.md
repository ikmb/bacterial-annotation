# Usage information

This pipeline is configured to run on the IKMB medCluster. More general support for other compute systems may follow later. 

## Basic example

```
nextflow run ikmb/bacterial-annotation --assemblies '/path/to/assemblies/*.fasta' --tools prokka,dfast
```

## Options

### `--samples`

A samplesheet to provide the relevant data to the pipeline. This is the preferred option, if possible. Else, see `--assemblies` below. 

```bash
nextflow run ikmb/bacterial-annotation --samples samples.csv --email 'me@somewhere.org'
```

The samplesheet format looks as follows:

```
sample,genus,species,strain,fasta,busco
MySample,Escherichia,coli,K12,/path/to/assembly.fa,bacteria_odb10
```

Note that the last column, busco, refers to a busco reference database to perform completeness checks against. Youn can find a full list [here](https://busco.ezlab.org/list_of_lineages.html). Note that you must only specify the first part of the name,
up to and including "odb10". 

### `--assemblies`

A regular expression pointing to a list of bacterial assemblies in FASTA format. This option is discouraged since it cannot provide useful metadata about genus, species and so on. These fields will all be filled with the name of the assembly file. 

```bash
nextflow run ikmb/bacterial-annotation --assemblies '/path/to/assemblies/*.fasta' --email 'me@somewhere.org'
```

### `--tools prokka,dfast`

This pipeline currently supports two annotation tools:

- [DFast_core](https://github.com/nigyta/dfast_core) [dfast]
- [Prokka](https://github.com/tseemann/prokka) [prokka]

Specify one or both tools - sperated by comma; results will be stored in the respective subfolder. Dfast tends to produce better results and is the recommended choice. 

### `--outdir` [default = "results" ]

The directory where to store the results. 

### `--dfast_options [ default = '--minimum_length 200']`

Set any compatible command line options for Dfast

### `--prokka_options [ default = '--compliant --centre CCGA']`

Set any compatible command line options for Prokka

### `--email`

Send the pipeline report to this email. Leave empty if you do not wish to recieve this email. 
