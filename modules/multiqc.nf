process MULTIQC {

   container 'quay.io/biocontainers/multiqc:1.12--pyhdfd78af_0'

   publishDir "${params.outdir}/MultiQC", mode: 'copy'
   
   input:
   path('*')

   output:
   path('multiqc_report.html'), emit: html

   script:

   """
      multiqc . 
   """	

}


