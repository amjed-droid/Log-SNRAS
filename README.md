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
- **Robust:** Tested on 151 adversarial light curves, achieving an AUC of 0.725 against complex astrophysical noise.

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
