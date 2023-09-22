process PROKKA {

    tag "${meta.sample}"

    container 'quay.io/biocontainers/prokka:1.14.6--pl5321hdfd78af_4'

    publishDir "${params.outdir}/prokka", mode: 'copy'

    input:
    tuple val(meta),path(fasta)

    output:
    path(results)
    path("versions.yml"), emit: versions
    path(report), emit: report
    
    script:
    base = meta.sample
    results = "prokka_${meta.sample}"
    report = "${results}/${base}.txt"
    """
    prokka --outdir $results \
        --prefix $base \
        --species ${meta.species} \
        --strain ${meta.strain} \
        --genus ${meta.genus} \
        --cpus ${task.cpus} \
        ${params.prokka_options} $fasta 
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prokka: \$(echo \$(prokka --version 2>&1) | sed 's/.* //' | tail -n1)
    END_VERSIONS

    """        
}
