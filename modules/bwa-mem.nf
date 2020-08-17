process bwaMem {

    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "${sampleName}.sorted.bam", mode: "copy"

    label 'bwa_mem'

    tag { sampleName }

    input:
    tuple val(fastqGroupingKey), path(fastq), val(reference)

    output:
    tuple val(sampleName), file("${sampleName}.sorted.bam")
    

    script:
    
    sampleName = fastq[0].getBaseName().split("_S[0-9]+_")[0]

    """
    ln -s ${reference}* .
    bwa mem -t 8 ${reference} ${fastq} | samtools sort -n -@ 8 -T "temp" -O BAM -o ${sampleName}.sorted.bam -
    """
}

process extractFastq {

    publishDir "${params.outdir}/output_fastq", pattern: "${sampleName}.dehosted_R*.fastq.gz", mode: "copy"

    label 'smallcpu'

    tag { sampleName }

    input:
    tuple val(sampleName), file(unmapped_bam)

    output:
    file("${sampleName}.dehosted_R*.fastq.gz")

    script:
    """
    samtools fastq -@ 4 ${unmapped_bam} -1 ${sampleName}.dehosted_R1.fastq.gz -2 ${sampleName}.dehosted_R2.fastq.gz -s ${sampleName}.singletons.fastq.gz
    """
}