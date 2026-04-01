# Log-SNRAS
**A Computationally Efficient Variance-Stabilized Metric for Vetting Heteroscedastic Light Curves**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language](https://img.shields.io/badge/MATLAB-R2020b%2B-blue.svg)](https://www.mathworks.com/products/matlab.html)

## Overview
**Log-SNRAS** (Logarithmic Signal-to-Noise Ratio with Adjusted Statistics) is a novel statistical metric designed to automate the vetting of exoplanet candidates in space-based photometry (e.g., *Kepler*, *TESS*). Unlike traditional SNR, which assumes homoscedastic (uniform) noise, Log-SNRAS introduces a logarithmic penalty term based on the **dispersion contrast ($\psi$)** between in-transit and out-of-transit flux.

This metric effectively penalizes instrumental artifacts and non-stationary noise events that mimic planetary signals, offering a robust $\mathcal{O}(N)$ alternative to computationally expensive deep learning models.

## Key Features
- **Variance-Aware:** Penalizes signals with high local instability (heteroscedasticity).
- **Computationally Efficient:** Linear time complexity $\mathcal{O}(N)$, suitable for large-scale surveys.
- **Interpretable:** Provides a clear diagnostic score without "black-box" inference.
- **Robust:** Tested on 151 adversarial light curves, achieving the highest AUC against complex astrophysical noise.

## Data Preparation
Light curves evaluated in this study were downloaded from the Mikulski Archive for Space Telescopes (MAST). The analysis specifically utilizes the Pre-search Data Conditioning Simple Aperture Photometry (PDCSAP) flux column. Pre-processing steps included standard quality-bit filtering to remove bad cadences and outlier clipping to prepare the light curves for robust statistical evaluation.

## Reproducibility & Figure Generation
This repository contains all necessary scripts and data to fully reproduce the results presented in the manuscript.
- **Figure & Table Generation:** Scripts are provided to regenerate every figure in the paper (including the 3D response surface in Figure 1 and all ROC curves) as well as the summary tables.
- **Environment:** The code was developed and tested using MATLAB R2025b.
- **Bootstrap Analysis:** The random seed used for the stratified bootstrap resampling ($B=2000$) is explicitly set within the scripts to guarantee exact reproduction of the reported $p$-values and confidence intervals.

## Supplementary Material
The complete 151-target evaluation catalog used for benchmarking (Table C.4 in the manuscript's supplementary material) is included in this repository to ensure full transparency and allow for future comparative studies.

## Usage
The core function `calculate_log_snras.m` is standalone.

```matlab
% Example Usage:
flux = ...; % Your normalized light curve
mask = ...; % Boolean vector (True = In-Transit)
snr_trad = ...; % Traditional SNR value

[score, penalty, psi] = calculate_log_snras(flux, snr_trad, mask);

fprintf('Log-SNRAS Score: %.2f\n', score);
fprintf('Stability Penalty: %.2f%%\n', (penalty-1)*100);
