include { CUSTOM_DUMPSOFTWAREVERSIONS }     from "./../modules/custom/dumpsoftwareversions/main"
include { MULTIQC }                         from './../modules/multiqc'
include { DFAST_CORE }                      from './../modules/dfast/core'
include { PROKKA }                          from "./../modules/prokka"

ch_assemblies = Channel.fromPath(params.assemblies)
ch_qc = Channel.from([])
ch_versions = Channel.from([])

tools = params.tools ? params.tools.split(',').collect{it.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '')} : []

workflow BACTERIAL_ANNOTATION {

    main:

    if ( 'dfast' in tools ) {

        DFAST_CORE(
            ch_assemblies,
            params.dfast_db_root
        )

        ch_versions = ch_versions.mix(DFAST_CORE.out.versions)
    }

    if ( 'prokka' in tools ) {

        PROKKA(
            ch_assemblies
        )

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
    qc = MULTIQC.out.report
	
}
