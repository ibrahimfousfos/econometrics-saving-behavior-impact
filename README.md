# econometrics-saving-behavior-impact

Analyse économétrique de l'impact d'un programme sur le comportement d'épargne des ménages — Groupe 41.

## Structure du projet

```
📂 econometrics-saving-behavior-impact
│
├── 📂 data
│   ├── group41.csv                  # La base de données brute
│   └── (données nettoyées si exportées)
│
├── 📂 scripts
│   ├── 01_data_exploration.R        # Partie 1 – Exploration des données
│   ├── 02_ols_probit_analysis.R     # Partie 2 – Modèles OLS et Probit
│   └── 03_did_impact_eval.R         # Partie 3 – Évaluation d'impact (DiD)
│
├── 📂 reports
│   ├── Groupe_41_Case_1Part1.pdf
│   ├── Groupe_41_Case_1Part2.pdf
│   ├── Groupe41_Case1_Part3.pdf
│   └── Cases_description.pdf        # Le sujet original
│
├── 📂 feedback                      # (Optionnel) Fichiers de notation
│
├── .gitignore                       # Fichiers temporaires R ignorés
└── README.md
```

## Description

| Partie | Contenu |
|--------|---------|
| **Partie 1** | Exploration et statistiques descriptives |
| **Partie 2** | Régressions OLS et modèles Probit |
| **Partie 3** | Évaluation d'impact par Différence-en-Différences (DiD) |

## Prérequis

- R ≥ 4.0
- Packages : `tidyverse`, `ggplot2`, `stargazer`, `lmtest`, `sandwich`, `corrplot`, `skimr`, `margins`
