include { CUSTOM_DUMPSOFTWAREVERSIONS }     from "./../modules/custom/dumpsoftwareversions/main"
include { MULTIQC }                         from './../modules/multiqc'
include { DFAST_CORE }                      from './../modules/dfast/core'
include { PROKKA }                          from "./../modules/prokka"
include { BUSCO_QC }                        from "./../subworkflows/busco_qc/main"

ch_qc = Channel.from([])
ch_versions = Channel.from([])
ch_proteins = Channel.from([])

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
    	  sample: a.getBaseName(),
    	  busco: "bacteria_odb10"
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
        DFAST_CORE.out.proteins.map { m,p ->
           [[
             sample: m.sample,
             genus: m.genus,
             species: m.species,
             strain: m.strain,
             busco: m.busco,
             tool: "DFAST"
           ],p ]
        }.set { dfast_proteins }
        
	ch_proteins = ch_proteins.mix(dfast_proteins)
        ch_versions = ch_versions.mix(DFAST_CORE.out.versions)
    }

    if ( 'prokka' in tools ) {

        PROKKA(
            ch_genomes
        )
	ch_qc = ch_qc.mix(PROKKA.out.report)
        ch_versions = ch_versions.mix(PROKKA.out.versions)
        
        PROKKA.out.proteins.map { m,p ->
           [[
             sample: m.sample,
             genus: m.genus,
             species: m.species,
             strain: m.strain,
             busco: m.busco,
             tool: "PROKKA"
           ],p ]
        }.set { prokka_proteins }
        
        ch_proteins = ch_proteins.mix(prokka_proteins)
    }

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )		
	
    ch_qc = ch_qc.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml)

    BUSCO_QC(
    	ch_proteins
    )
    
    ch_qc = ch_qc.mix(BUSCO_QC.out.busco_summary)
    ch_versions = ch_versions.mix(BUSCO_QC.out.versions)
        
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
    meta.busco = row.busco
                                                            
    def array = []
    array = [ meta, file(row.fasta) ]
                                                   
    return array
    
}
