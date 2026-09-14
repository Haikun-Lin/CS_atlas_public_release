# Cross-disease single-cell cytokine storm atlas

This repository contains downstream analysis code associated with the
cross-disease single-cell cytokine storm atlas manuscript.

The repository is notebook-centered. The notebooks and CellChat scripts record
the downstream analyses used for figure generation and selected source tables.
Raw sequencing data, processed AnnData objects, RDS files, matrix files, and
patient-level private information are not included.

## Notebooks

- `notebooks/01_global_atlas_analysis.ipynb` - integrated immune-cell atlas,
  global QC and integration assessment, cytokine-storm scoring, global figures
  and tables, CellChat input preparation, and selected pDC and B cell analyses.
- `notebooks/02_myeloid_monocyte_analysis.ipynb` - cross-disease myeloid and
  monocyte analyses, including COVID-19, SLE, and CAR-T-associated analyses.
- `notebooks/03_t_lineage_cart_analysis.ipynb` - T-lineage and CAR-T cohort
  analyses.
- `notebooks/04_mae_monocyte_input_build.ipynb` - construction of the frozen
  monocyte input, including balanced-consensus HVG5000 feature selection,
  metadata checks, and export of the analysis-ready AnnData object.
- `notebooks/05_mae_model_training.ipynb` - five-seed masked-autoencoder model
  training, latent representation export, model-history recording, and
  seed-neighborhood stability QC.
- `notebooks/06_mae_figure6_analysis.ipynb` - masked-autoencoder analysis and
  figure-generation workflow for Fig. 6, including clinical risk localization,
  training convergence, attribution, reference-state reversion, K90 gene-set
  analysis, atlas-program reversion, and predicted regulator visualization.
- `notebooks/07_mae_supplementary_figure6_analysis.ipynb` - supplementary
  Fig. S6 workflow, including seed-neighborhood stability, matched-control
  calibration, seed-wise K90 stability, disease-specific K90 expression
  summaries, and the quadrant scaffold.

## CellChat scripts

Standalone CellChat workflows are stored in `scripts/cellchat/`:

- `run_cellchat_cart.R`
- `run_cellchat_covid19.R`
- `run_cellchat_sle.R`
- `analyze_cellchat_cart.R`
- `analyze_cellchat_covid19.R`
- `analyze_cellchat_sle.R`

The Python notebooks prepare CellChat input folders. The R scripts run CellChat
and generate downstream CellChat summaries and plots.

## Environment

Compact environment records are provided in `environment/`:

- `methods_software_table.csv`
- `python_requirements_public.txt`

Package versions should be interpreted as the analysis environment used for the
public code release. Standard-library modules and full transitive dependency
lists are not exhaustively reported.

## Data and paths

Large biological data objects are not tracked. Notebook setup cells document
environment-variable names for private input files and output folders, such as
`ATLAS_H5AD`, `MYELOID_H5AD`, `T_LINEAGE_H5AD`, MAE analysis path variables,
and CellChat-specific path variables.

Local paths, patient-level private information, processed AnnData objects,
matrix files, and RDS files should not be committed.

