# Log-SNRAS
**A Computationally Efficient Variance-Stabilized Metric for Vetting Heteroscedastic Light Curves**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language](https://img.shields.io/badge/MATLAB-R2025b%2B-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![Release](https://img.shields.io/badge/Release-v1.1--revised-success.svg)](#)

## Overview
**Log-SNRAS** (Logarithmic Signal-to-Noise Ratio with Adjusted Statistics) is a computationally efficient **post-detection vetting filter** designed to automate the evaluation of exoplanet candidates in space-based photometry (e.g., *Kepler*, *TESS*). 

Unlike traditional search algorithms (like BLS or TPS) or standard SNR metrics which assume homoscedastic (uniform) noise, Log-SNRAS operates *after* detection. It introduces a physically motivated logarithmic penalty term based on the **dispersion contrast ($\psi$)** between in-transit and out-of-transit flux. This allows it to penalize instrumental artifacts and non-stationary noise events (heteroscedasticity) that often mimic planetary signals.

**Formula:**
$$\text{Log-SNRAS} = \frac{\delta}{\sigma_{out}} \times \frac{\sqrt{N_{in}}}{1 + \ln(1 + \psi)}$$

## Reproducibility Statement
A major strength of this work is its complete reproducibility. This repository contains all necessary scripts, exact random seeds, and data to fully reproduce the results, tables, and figures presented in the revised manuscript.

* **Environment:** Developed and tested using **MATLAB R2025b**. 
* **Required Toolboxes:** `Statistics and Machine Learning Toolbox`.
* **Random Seed:** A fixed seed (`rng(42)`) is explicitly set in the scripts for the stratified bootstrap resampling ($B=2000$) to guarantee the exact reproduction of the reported $p$-values and 95% Confidence Intervals (CIs).
* **Release Tag:** The results in the manuscript correspond to the `v1.1-revised` tag of this repository.

## Data Preparation & Pre-processing
Light curves evaluated in the empirical benchmark were downloaded from the Mikulski Archive for Space Telescopes (MAST). 
* **Flux Selection:** The analysis specifically utilizes the Pre-search Data Conditioning Simple Aperture Photometry (PDCSAP) flux column.
* **Pre-processing:** Steps included standard quality-bit filtering to remove bad cadences, outlier clipping, and precise windowing. The in-transit window is defined as the interval $\pm T_{dur}/2$ centered on the BLS mid-transit time, while the out-of-transit window utilizes the remaining points after removing a $2 \times T_{dur}$ buffer on each side.

## Figure Generation & Scripts
The following scripts are provided to automatically regenerate the manuscript's core results:
* `reproduce_table1_bootstrap.m`: Executes a stratified bootstrap ($B=2000$) on the 151-target adversarial dataset. It outputs the exact **Mean AUC** and **95% CIs** shown in **Table 1**.
* `generate_roc_analysis.m`: Generates the high-resolution empirical ROC curve benchmarking the evaluated metrics, as shown in **Figure 2**.
* `generate_table2_stats.m`: Dynamically parses the raw TESS/Kepler FITS files to compute the exact class balance, median dispersion contrast ($\psi$), and median penalty values presented in **Table 2**.
* `plot_3d_surface.m`: Regenerates the 3D response surface shown in **Figure 1**, mapping the theoretical penalty behavior across various noise regimes.
  
## Supplementary Material & Data Notes
The complete 151-target evaluation catalog used for benchmarking is included as `Supplementary_Table_C4.csv`.
> **Note on NaNs:** Any `NaN` values present in the supplementary tables correspond to light curve segments with an insufficient number of in-transit points ($N_{in} < 10$), which were excluded from the final statistical evaluation to prevent undefined penalty behavior.

## Usage
The core function `calculate_log_snras.m` is standalone and operates in $\mathcal{O}(N)$ linear time.

```matlab
% Example Usage:
flux = ...; % Your normalized light curve array
mask = ...; % Boolean vector (True = In-Transit)
snr_trad = ...; % Traditional SNR value computed by your pipeline

[score, penalty, psi] = calculate_log_snras(flux, snr_trad, mask);

fprintf('Log-SNRAS Score: %.2f\n', score);
fprintf('Stability Penalty: %.2f%%\n', (penalty-1)*100);
