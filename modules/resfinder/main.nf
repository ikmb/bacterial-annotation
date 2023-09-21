process RESFINDER {

    tag "${meta.sample_id}"

    label 'medium_parallel'

    container 'quay.io/biocontainers/resfinder:4.1.11--hdfd78af_0'

    publishDir "${params.outdir}/${meta.sample_id}/Resfinder", mode: 'copy'

    input:
    tuple val(meta),path(R1),path(R2)

    output:
    tuple val(meta),path(ptable), emit: phenotable
    path("version.yml"), emit: versions

    script:
    ptable = "results/pheno_table.txt"
    json = meta.sample_id + ".json"

    """
    resfinder -ifq ${R1} ${R2}-o results -s ${meta.species} -l 0.5 -t 0.8 -db_res ${params.resfinder_db} -j $json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        resfinder: \$(resfinder --version 2>&1 | sed -e "s/resfinder //g")
    END_VERSIONS

    """

}
