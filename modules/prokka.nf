process PROKKA {

	tag "${fasta}"

	container 'quay.io/biocontainers/prokka:1.14.6--pl5321hdfd78af_4'

	publishDir "${params.outdir}/prokka", mode: 'copy'

	input:
	path(fasta)

	output:
	path(results)

	script:
	base = fasta.getSimpleName()
	results = "prokka_${base}"

	"""
		prokka --outdir $results \
			--prefix $base \
			--compliant \
			--centre CCGA \
			--cpus ${task.cpus} \
			$fasta 
	"""		
}
