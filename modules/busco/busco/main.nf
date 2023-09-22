process BUSCO_BUSCO {
    tag "${meta.sample} |${meta.tool}|${meta.busco}"
    
    label 'process_high'

    container 'https://depot.galaxyproject.org/singularity/busco:5.3.0--pyhdfd78af_0'

    publishDir "${params.outdir}/${meta.sample}/busco/", mode: 'copy'
    
    input:
    tuple val(meta), path(proteins)
    val(db_path)

    output:
    path(busco_summary), emit: summary
    path "versions.yml"           , emit: versions

    script:
    busco_summary = "short_summary_" + meta.sample + "_" + meta.tool + ".txt"
    def options = ""
    
    """

    busco -m proteins -i $proteins $options -l ${db_path}/${meta.busco} -o busco -c ${task.cpus} --offline
    cp busco/short_summary*specific*busco.txt $busco_summary
    rm -Rf busco

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$(echo \$(busco -version 2>&1) | cut -f2 -d " " ))
    END_VERSIONS
    """
}
