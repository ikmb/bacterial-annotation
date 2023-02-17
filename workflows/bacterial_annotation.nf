include { SOFTWARE_VERSIONS } from '../modules/software_versions'
include { MULTIQC } from './../modules/multiqc'
include { DFAST_CORE } from './../modules/dfast/core'

ch_assemblies = Channel.fromPath(params.assemblies)
ch_qc = Channel.from([])
ch_versions = Channel.from([])

workflow BACTERIAL_ANNOTATION {

	main:

	DFAST_CORE(
		ch_assemblies,
		params.db_root
	)

	SOFTWARE_VERSIONS(
		ch_versions.collect()
	)		
	
        MULTIQC(
           ch_qc.collect()
        )

	emit:
	qc = MULTIQC.out.report
	
}
