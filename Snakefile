# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

from snakemake.utils import min_version

min_version("4.1.0")

UNIT_TO_SAMPLE = {
    unit: sample for sample, units in config["samples"].items()
    for unit in units}

# Output file format; possible values: bam, cram
OUTPUT_FORMAT = 'cram'
# Output file format; possible values: bai, crai
INDEX_FORMAT = 'crai'

rule all:
    input: expand("reads/merged_samples/{sample}.{output_format}", \
                  sample=config["samples"], \
                  output_format=OUTPUT_FORMAT),
           expand("reads/merged_samples/{sample}.{output_format}.flagstat", \
                  sample=config["samples"], \
                  output_format=OUTPUT_FORMAT),
           expand("reads/merged_samples/{sample}.{output_format}.{index_format}", \
                  sample=config["samples"], \
                  output_format=OUTPUT_FORMAT, \
                  index_format=INDEX_FORMAT)

include_prefix="rules"

include:
    include_prefix + "/functions.py"
include:
    include_prefix + "/bwa_mem.rules"	
include:
    include_prefix + "/samtools.rules"

