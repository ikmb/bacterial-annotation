process DFAST_CORE {

    tag "$fasta"

    container 'quay.io/biocontainers/dfast:1.2.18--h5b5514e_1'

    publishDir "${params.outdir}/dfast", mode: 'copy'

    input:
    path(fasta)
    env DFAST_DB_ROOT

    output:
    path(results), emit: results
    path(report), emit: report
    path("versions.yml"), emit: versions
    
    script:
    base_name = fasta.getBaseName()
    results = base_name + "_dfast"
    report = base_name + ".statistics.txt"

    """
    dfast --genome $fasta ${params.dfast_options} -o $results --cpu ${task.cpus}
    cp "${results}/statistics.txt" $report

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dfast: \$(echo \$(dfast --version 2>&1) | sed 's/.* //')
    END_VERSIONS
    """
}
