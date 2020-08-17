

process bwa_mem {

    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "${sampleName}.sorted.bam", mode: "copy"

    label 'bwa_mem'

    tag { sampleName }

    input:
    tuple path(fastq), file(reference)

    output:
    tuple sampleName, file("${sampleName}.sorted.bam")
    

    script:
    sampleName = fastq.getBaseName().replaceAll(~/\.fastq.*$/, '')

    """
    bwa mem -t 8 ${reference} ${fastq} | samtools sort -@ 8 -T "temp" -O BAM -o ${sampleName}.sorted.bam -
    """
}
