process DFAST_CORE {

    tag "${meta.sample}"

    container 'quay.io/biocontainers/dfast:1.2.18--h5b5514e_1'

    publishDir "${params.outdir}/${meta.sample}/dfast", mode: 'copy'

    input:
    tuple val(meta),path(fasta)
    env DFAST_DB_ROOT

    output:
    path(results), emit: results
    path(report), emit: report
    tuple val(meta),path("${results}/protein.faa"), emit: proteins
    path("versions.yml"), emit: versions
    
    script:
    base_name = meta.sample
    results = base_name + "_dfast"
    report = base_name + ".statistics.txt"
    organism = meta.genus + "_" + meta.species
    strain = meta.strain
    """
    dfast --genome $fasta ${params.dfast_options} --organism ${organism} --strain $strain -o $results --cpu ${task.cpus}
    cp "${results}/statistics.txt" $report

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dfast: \$(echo \$(dfast --version 2>&1) | sed 's/.* //')
    END_VERSIONS
    """
}
