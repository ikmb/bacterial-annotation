include { SOFTWARE_VERSIONS } from '../modules/software_versions'
include { MULTIQC } from './../modules/multiqc'
include { DFAST_CORE } from './../modules/dfast/core'
include { PROKKA } from "./../modules/prokka"

ch_assemblies = Channel.fromPath(params.assemblies)
ch_qc = Channel.from([])
ch_versions = Channel.from([])

tools = params.tools ? params.tools.split(',').collect{it.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '')} : []

workflow BACTERIAL_ANNOTATION {

	main:

	if ( 'dfast' in tools ) {

		DFAST_CORE(
			ch_assemblies,
			params.db_root
		)
	}

	if ( 'prokka' in tools ) {

		PROKKA(
			ch_assemblies
		)

	}

	//ch_qc = ch_qc.mix(DFAST_CORE.out.report)

	SOFTWARE_VERSIONS(
		ch_versions.collect()
	)		
	
        MULTIQC(
           ch_qc.collect()
        )

	emit:
	qc = MULTIQC.out.report
	
}
