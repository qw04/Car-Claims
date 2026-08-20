# Reads the raw freMTPL2freq parquet export and writes a cleaned CSV
# used by analysis.Rmd. Run once: Rscript R/01_prepare_data.R

library(nanoparquet)
library(dplyr)
library(readr)

raw <- read_parquet("data/raw/freMTPL2freq_raw.pq")

cat("Raw dimensions:", nrow(raw), "rows x", ncol(raw), "cols\n")
cat("Columns:", paste(names(raw), collapse = ", "), "\n")
str(raw)

# --- Data cleaning -----------------------------------------------------
# freMTPL2freq is known (Noll, Salzmann & Wuethrich 2020) to contain a
# small number of data-entry artefacts: Exposure values above 1 policy-year,
# and a handful of policies with implausibly high claim counts relative to
# their exposure. We check for these directly in the downloaded data rather
# than assuming they're present, and cap them if found.

cat("\n--- Exposure summary ---\n")
print(summary(raw$Exposure))
cat("Policies with Exposure > 1:", sum(raw$Exposure > 1), "\n")

cat("\n--- ClaimNb summary ---\n")
print(table(raw$ClaimNb))

clean <- raw %>%
  mutate(
    Exposure = pmin(Exposure, 1),
    ClaimNb = pmin(ClaimNb, 4),          # cap extreme counts (documented data-entry outliers)
    VehAge = pmin(VehAge, 40),
    DrivAge = pmin(DrivAge, 90),
    Area = factor(Area, ordered = FALSE),
    VehBrand = factor(VehBrand),
    VehGas = factor(VehGas),
    Region = factor(Region)
  ) %>%
  filter(Exposure > 0)                    # a zero-exposure policy carries no information

cat("\nClean dimensions:", nrow(clean), "rows x", ncol(clean), "cols\n")
cat("Rows dropped:", nrow(raw) - nrow(clean), "\n")

dir.create("data", showWarnings = FALSE)
write_csv(clean, "data/freMTPL2freq_clean.csv")
cat("\nWrote data/freMTPL2freq_clean.csv\n")
