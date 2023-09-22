process MULTIQC {

   container 'quay.io/biocontainers/multiqc:1.12--pyhdfd78af_0'

   publishDir "${params.outdir}/MultiQC", mode: 'copy'
   
   input:
   path('*')

   output:
   path("${params.run_name}_multiqc_report.html"), emit: html

   script:

   """
      cp ${baseDir}/conf/multiqc_config.yaml .
      multiqc -n ${params.run_name}_multiqc_report . 
   """	

}


