# ECON1430-Capstone
# Replication Package: Recreational Marijuana Legalization and Crime

This repository contains the full replication materials for an event study analyzing the impact of recreational marijuana legalization on crime rates across U.S. states.

## Contents

- `master.do` – The full Stata script that runs data processing, estimation, plotting, and placebo checks.
- `Copy of Cleaned State Data - Sheet1.csv` – Cleaned input data with state-level panel data on crime and legalization dates.
- Generated outputs include:
  - ATT plots for total, property, and violent crime
  - Placebo test plots
  - Summary statistics by treatment status
  - Table of treated states with legalization years

## How to Run

1. Open `master.do` in Stata 17+
2. Ensure you have the required packages:
   ssc install did_imputation, replace
   ssc install event_plot, replace
