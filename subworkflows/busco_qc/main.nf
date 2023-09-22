include { BUSCO_BUSCO as BUSCO } from '../../modules/busco/busco/main'

ch_versions = Channel.from([])

workflow BUSCO_QC {

    take:
    proteins

    main:

   //
   // MODULE: Download the BUSCO database for this taxonomic group
   //

    
   //
   // MODULE: Run BUSCO on the protein sets
   //
    BUSCO(
        proteins,
        params.busco_db_path
    )

    ch_versions = ch_versions.mix(BUSCO.out.versions)

    emit:
    busco_summary = BUSCO.out.summary
    versions = ch_versions

}

