# Econometrics Project — Impact of Sales Meetings on Saving Behavior

## Overview

This repository contains our applied econometrics project based on **Case 1**, which studies the impact of a **salesperson meeting** on clients’ saving behavior.

The objective is to evaluate whether meeting a salesperson affects:
- **total savings**
- **retirement savings**

The project is divided into **three parts**, following the progression of the course:
1. **Data exploration and research question**
2. **OLS / Probit analysis**
3. **Impact evaluation with Difference-in-Differences (DiD)**

---

## Project Context

We worked on a panel dataset of bank clients observed over multiple time periods.  
A treatment (meeting with a salesperson) is introduced during the observation window, which makes the dataset suitable for a causal analysis framework.

This project was completed as part of an **econometrics course** and includes:
- data exploration
- variable transformations
- regression analysis (OLS, Probit)
- causal impact evaluation (DiD, fixed effects)
- interpretation and discussion of results

---

## Repository Structure

```text
econometrics-saving-behavior-impact/
│
├── data/
│   └── bank_clients_panel.csv
│
├── scripts/
│   ├── 01_data_exploration.R
│   ├── 02_ols_probit_analysis.R
│   └── 03_did_impact_eval.R
│
├── reports/
│   ├── case_description.pdf
│   ├── econometrics_case1_part1.pdf
│   ├── econometrics_case1_part2.pdf
│   └── econometrics_case1_part3.pdf
│
├── feedback/
│   └── feedback_summary.md
│
├── outputs/
│   ├── figures/
│   └── tables/
│
├── .gitignore
└── README.md
```

---

## Data

- **File:** `data/bank_clients_panel.csv`
- Panel dataset of clients observed over several periods
- Main variables include:
  - client identifier (`id`)
  - time period (`time`)
  - income
  - savings
  - retirement savings
  - treatment indicator (`meeting`)
  - demographic controls (e.g. age, gender)

The original case description is available in:
- `reports/case_description.pdf`

---

## Methods Used

### Part 1 — Data Exploration
- Research question and hypothesis formulation
- Initial descriptive analysis
- Variable inspection and first transformations

### Part 2 — OLS / Probit Analysis
- Descriptive statistics by treatment/control groups
- OLS regressions
- Probit model (for treatment assignment / balance checks)
- Interpretation of coefficients and statistical significance

### Part 3 — Causal Impact Evaluation
- Difference-in-Differences (DiD)
- Fixed effects panel regression
- Placebo test
- Heterogeneity analysis (e.g. by gender)

---

## Main Learning Outcomes

This project helped us practice and better understand:

- how to move from a **research question** to an econometric strategy
- how to work with **panel data**
- the difference between **correlation** and **causal interpretation**
- how to use **OLS, Probit, and DiD** in a coherent workflow
- how to interpret regression results in an economic context

It also helped us improve the quality of our work across the three submissions (structure, methodology, and interpretation).

---

## Reproducibility

The analysis is written in **R**.

To run the scripts, place the dataset in the `data/` folder and run the scripts in order:

```r
source("scripts/01_data_exploration.R")
source("scripts/02_ols_probit_analysis.R")
source("scripts/03_did_impact_eval.R")
```

> Note: some scripts may require package installation (e.g. `dplyr`, `ggplot2`, `fixest`, `margins`, etc.).

---

## Notes on Feedback and Improvements

A summary of the feedback received during the project and the improvements made between parts is available in:

- `feedback/feedback_summary.md`

This helps document our progression and the methodological refinements made throughout the project.

---

## Authors

Group 41 — Econometrics Project (Case 1)

---

## License

This repository is shared for academic and portfolio purposes.
