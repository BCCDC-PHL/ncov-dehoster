#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl = 2

// Modules
include { bwaMem } from './modules/bwa-mem.nf'
include { samtoolsFlagstat } from './modules/minimap.nf'
include { removeMappedReads } from './modules/minimap.nf'
include { extractFastq } from './modules/bwa-mem.nf'


if ( !params.directory ) {
    println('Please supply a directory containing fastq files with directory.')
    System.exit(1)
}

// Main
workflow {

    Channel.fromFilePairs( "${params.directory}/*_R{1,2}_*.fastq.gz", type: 'file', maxDepth: 1 )
                        .set{ ch_fastq }

    Channel.fromPath( "${params.reference}")
                        .set{ ch_ref }

    bwaMem(ch_fastq.combine(ch_ref))

    samtoolsFlagstat(bwaMem.out)

    removeMappedReads(bwaMem.out)

    extractFastq(removeMappedReads.out)
}