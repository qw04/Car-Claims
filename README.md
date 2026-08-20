# Insurance Claims Rate Modelling with GLMs

Poisson and negative binomial GLMs for motor insurance claim frequency, fit
in R with offset(log(Exposure)) rate modelling, AIC/likelihood-ratio model
comparison, residual diagnostics, and visualised predicted rates with
confidence intervals.

**[Read the full analysis report](https://qw04.github.io/Car-Claims/analysis.html)**

## Data

[`freMTPL2freq`](https://www.openml.org/d/41214): 677,991 French motor
third-party liability policies, originally distributed via the
[CASdatasets](https://github.com/dutangc/CASdatasets) R package for
*Computational Actuarial Science with R* (Charpentier, ed., CRC Press,
2018), downloaded here via its OpenML mirror. Each row is a policy-year
with a claim count (`ClaimNb`), an exposure fraction (`Exposure`, in
policy-years), and rating factors (driver age, vehicle age/power,
bonus-malus, area, region, vehicle brand/fuel, population density).

Raw data: `data/raw/freMTPL2freq_raw.pq`
Cleaned data: `data/freMTPL2freq_clean.csv` (produced by `R/01_prepare_data.R`)

## Reproducing

```r
# from the project root, e.g. after opening Car-Claims.Rproj
source("R/01_prepare_data.R")     # raw parquet -> cleaned CSV
rmarkdown::render("analysis.Rmd") # full analysis -> analysis.html
```

## Approach

1. **Data cleaning** — cap known data-entry artefacts (exposure > 1
   policy-year, implausible claim counts) documented in the actuarial
   literature on this dataset, verified against the actual downloaded data
   rather than assumed.
2. **Poisson GLM for rates** — `ClaimNb ~ rating factors`, `offset(log(Exposure))`,
   log link, so fitted coefficients are interpreted as relativities on the
   claim frequency (claims per policy-year).
3. **Overdispersion check** — Pearson dispersion statistic against the
   Poisson model; negative binomial GLM (`MASS::glm.nb`) fit as the
   overdispersion-robust alternative.
4. **Model comparison** — AIC/BIC across candidate models, likelihood-ratio
   tests for nested Poisson models, and a boundary-corrected LR test for
   Poisson vs. negative binomial (computed directly rather than via
   `pscl::odTest`, which mishandles this model's offset term).
5. **Diagnostics** — deviance/Pearson residuals, leverage and Cook's
   distance, and DHARMa simulated-residual diagnostics for the count GLM.
6. **Predicted rates** — fitted claim frequency by rating factor with
   confidence bands, holding other factors at reference levels.

## Skills demonstrated

Poisson/negative binomial GLMs, offset/rate modelling, AIC/LRT model
selection, residual and influence diagnostics, R Markdown, `dplyr`/`ggplot2`.
