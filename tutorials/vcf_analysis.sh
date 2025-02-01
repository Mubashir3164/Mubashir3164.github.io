#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_vcf_file>"
    exit 1
fi

INPUT_VCF=$1
OUTPUT_DIR="vcf_analysis_output"
mkdir -p $OUTPUT_DIR

# Count the total number of variants
TOTAL_VARIANTS=$(bcftools view -H $INPUT_VCF | wc -l)
echo "Total variants: $TOTAL_VARIANTS" > $OUTPUT_DIR/summary.txt

# Count the number of SNPs
SNPS=$(bcftools view -H -v snps $INPUT_VCF | wc -l)
echo "SNPs: $SNPS" >> $OUTPUT_DIR/summary.txt

# Count the number of INDELs
INDELS=$(bcftools view -H -v indels $INPUT_VCF | wc -l)
echo "INDELs: $INDELS" >> $OUTPUT_DIR/summary.txt

# Calculate Transition/Transversion ratio
bcftools view -v snps $INPUT_VCF | vcftools --vcf - --TsTv-summary --out $OUTPUT_DIR/TsTv
if [ -f "$OUTPUT_DIR/TsTv.TsTv.summary" ]; then
    TsTv_RATIO=$(grep "Ts/Tv" $OUTPUT_DIR/TsTv.log | awk '{print $3}')
    echo "Ts/Tv ratio: $TsTv_RATIO" >> $OUTPUT_DIR/summary.txt
else
    echo "Ts/Tv ratio: N/A (No SNPs or calculation failed)" >> $OUTPUT_DIR/summary.txt
fi

# Generate allele frequency spectrum
vcftools --vcf $INPUT_VCF --freq --out $OUTPUT_DIR/allele_freq

echo "Analysis complete. Results are in the $OUTPUT_DIR directory."
