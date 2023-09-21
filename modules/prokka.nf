process PROKKA {

    tag "${fasta}"

    container 'quay.io/biocontainers/prokka:1.14.6--pl5321hdfd78af_4'

    publishDir "${params.outdir}/prokka", mode: 'copy'

    input:
    path(fasta)

    output:
    path(results)
    path("versions.yml"), emit: versions

    script:
    base = fasta.getSimpleName()
    results = "prokka_${base}"

    """
    prokka --outdir $results \
        --prefix $base \
        --cpus ${task.cpus} \
        ${params.prokka_options} $fasta 
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prokka: \$(echo \$(prokka --version 2>&1) | sed 's/.* //' | tail -n1)
    END_VERSIONS

    """        
}
