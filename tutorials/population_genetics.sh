#!/bin/bash
set -euo pipefail

# Population Genomics Analysis Pipeline (10kb Windows)
INPUT_VCF="input.vcf"
POP1="pop1.txt"
POP2="pop2.txt"
WINDOW_SIZE=10000    # 10kb window
STEP_SIZE=5000       # 5kb step for sliding windows
OUTDIR="population_analysis_results"

# Create output directory structure
mkdir -p ${OUTDIR}/{stats,plots}

echo "［1/5］ Calculating Nucleotide Diversity (π) in 10kb Sliding Windows"
vcftools --vcf ${INPUT_VCF} \
    --window-pi ${WINDOW_SIZE} \
    --window-pi-step ${STEP_SIZE} \
    --out ${OUTDIR}/stats/pi

echo "［2/5］ Calculating Tajima's D in 10kb Windows"
vcftools --vcf ${INPUT_VCF} \
    --TajimaD ${WINDOW_SIZE} \
    --out ${OUTDIR}/stats/tajima

echo "［3/5］ Calculating Windowed FST (10kb sliding)"
vcftools --vcf ${INPUT_VCF} \
    --weir-fst-pop ${POP1} \
    --weir-fst-pop ${POP2} \
    --fst-window-size ${WINDOW_SIZE} \
    --fst-window-step ${STEP_SIZE} \
    --out ${OUTDIR}/stats/fst

echo "［4/5］ Generating Visualization Reports"
python3 << EOF
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

sns.set_style("whitegrid")
plt.rcParams.update({'font.size': 12, 'figure.figsize': (12,6)})

# Plot Windowed Pi
pi = np.genfromtxt("${OUTDIR}/stats/pi.windowed.pi",
                  skip_header=1,
                  usecols=(1,4),  # Window position and Pi value
                  names=['POS','PI'])
plt.figure()
plt.scatter(pi['POS'], pi['PI'], s=10, alpha=0.7, color='darkorange')
plt.title("Nucleotide Diversity (π) in 10kb Sliding Windows")
plt.xlabel("Genomic Position (bp)")
plt.ylabel("π")
plt.savefig("${OUTDIR}/plots/pi_windows.png", dpi=300, bbox_inches='tight')

# Plot Tajima's D
tajima = np.genfromtxt("${OUTDIR}/stats/tajima.Tajima.D",
                      skip_header=1,
                      usecols=(1,3),  # Window position and D value
                      names=['POS','D'])
plt.figure()
plt.scatter(tajima['POS'], tajima['D'], s=10, alpha=0.7, color='royalblue')
plt.axhline(0, color='red', linestyle='--', linewidth=1)
plt.title("Tajima's D in 10kb Windows")
plt.xlabel("Genomic Position (bp)")
plt.ylabel("Tajima's D")
plt.savefig("${OUTDIR}/plots/tajima_windows.png", dpi=300, bbox_inches='tight')

# Plot Windowed FST
fst = np.genfromtxt("${OUTDIR}/stats/fst.windowed.weir.fst",
                   skip_header=1,
                   usecols=(1,5),  # Window position and mean FST
                   names=['POS','FST'])
plt.figure()
plt.scatter(fst['POS'], fst['FST'], s=10, alpha=0.7, color='forestgreen')
plt.title("Population FST in 10kb Sliding Windows")
plt.xlabel("Genomic Position (bp)")
plt.ylabel("FST")
plt.ylim(-0.05, 1.05)
plt.savefig("${OUTDIR}/plots/fst_windows.png", dpi=300, bbox_inches='tight')
EOF

echo "［5/5］ Generating HTML Report"
cat << HTML > ${OUTDIR}/report.html
<!DOCTYPE html>
<html>
<head>
    <title>10kb Window Analysis Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 2em }
        .plot { margin: 2em 0; border-bottom: 1px solid #eee; padding-bottom: 2em }
        img { max-width: 100%; box-shadow: 0 2px 4px rgba(0,0,0,0.1) }
        table { border-collapse: collapse; margin: 1em 0 }
        td, th { border: 1px solid #ddd; padding: 8px }
    </style>
</head>
<body>
    <h1>10kb Window Analysis Report</h1>
    
    <div class="plot">
        <h2>Nucleotide Diversity (π)</h2>
        <img src="plots/pi_windows.png">
        <p>Window configuration: ${WINDOW_SIZE}bp windows, ${STEP_SIZE}bp step</p>
    </div>

    <div class="plot">
        <h2>Tajima's D Distribution</h2>
        <img src="plots/tajima_windows.png">
        <p>Non-overlapping ${WINDOW_SIZE}bp windows</p>
    </div>

    <div class="plot">
        <h2>Sliding Window FST</h2>
        <img src="plots/fst_windows.png">
        <p>Sliding window configuration: ${WINDOW_SIZE}bp size, ${STEP_SIZE}bp step</p>
    </div>
</body>
</html>
HTML

echo "Analysis complete. Open ${OUTDIR}/report.html to view results."
