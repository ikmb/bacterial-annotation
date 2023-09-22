include { CUSTOM_DUMPSOFTWAREVERSIONS }     from "./../modules/custom/dumpsoftwareversions/main"
include { MULTIQC }                         from './../modules/multiqc'
include { DFAST_CORE }                      from './../modules/dfast/core'
include { PROKKA }                          from "./../modules/prokka"

ch_qc = Channel.from([])
ch_versions = Channel.from([])

tools = params.tools ? params.tools.split(',').collect{it.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '')} : []

if (params.samples) {
    Channel.fromPath(params.samples)
    .splitCsv ( header: true, sep: ',')
    .map { assembly_channel(it) }
    .set { ch_genomes }
} else {
    Channel.fromPath(params.assemblies)
    .map { a -> [
    	[ species: a.getBaseName(),
    	  genus: a.getBaseName(),
    	  strain: a.getBaseName(),
    	  sample: a.getBaseName()
        ],a
     ]}
    .set { ch_genomes }
}

workflow BACTERIAL_ANNOTATION {

    main:

    if ( 'dfast' in tools ) {

        DFAST_CORE(
            ch_genomes,
            params.dfast_db_root
        )

        ch_versions = ch_versions.mix(DFAST_CORE.out.versions)
    }

    if ( 'prokka' in tools ) {

        PROKKA(
            ch_genomes
        )
	ch_qc = ch_qc.mix(PROKKA.out.report)
        ch_versions = ch_versions.mix(PROKKA.out.versions)
    }

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )		
	
    ch_qc = ch_qc.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml)

    MULTIQC(
        ch_qc.collect()
    )

    emit:
    qc = MULTIQC.out.html
	
}

def assembly_channel(LinkedHashMap row) {
    
    def meta = [:]
    meta.sample = row.sample
    meta.species = row.species
    meta.genus = row.genus
    meta.strain = row.strain
                                                        
    def array = []
    array = [ meta, file(row.fasta) ]
                                                   
    return array
    
}
