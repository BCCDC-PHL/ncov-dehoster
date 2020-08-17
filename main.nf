#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl = 2

// Modules
include copyReference from './modules/minimap.nf'
include bwa_mem from './modules/bwa-mem.nf'
include samtoolsFlagstat from './modules/minimap.nf'
include removeMappedReads from './modules/minimap.nf'
include extractFastq from './modules/minimap.nf'


if ( !params.directory ) {
    println('Please supply a directory containing fastq files with directory.')
    System.exit(1)
}

// Main
workflow {

    Channel.fromPath( "${params.directory}/*.fastq.gz", type: 'file', maxDepth: 1 )
                        .set{ ch_fastq }

    Channel.fromPath( "${params.reference}")
                        .set{ ch_ref }

    copyReference(ch_ref)

    bwa_mem(ch_fastq
                .combine(copyReference.out))

    samtoolsFlagstat(bwa_mem.out)

    removeMappedReads(bwa_mem.out)

    extractFastq(removeMappedReads.out)
}