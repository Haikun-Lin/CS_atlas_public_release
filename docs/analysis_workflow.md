# Analysis workflow

This repository contains downstream, object-centered analysis workflows for the
cross-disease single-cell cytokine storm atlas. The three notebooks are the
primary analytical records. Standalone R scripts are used for CellChat execution
and downstream CellChat visualizations.

## Notebook 1: global atlas

`notebooks/01_global_atlas_analysis.ipynb`

Major workflow areas:

1. Environment setup, path configuration, processed-object loading, and object
   validation.
2. Object and metadata inspection and sample-type mapping.
3. QC inspection and sample-level statistics.
4. Atlas composition, Sankey, cell-count, and UMAP visualization.
5. Integration-quality assessment using seeded downsampling and mixing entropy.
6. Subcluster marker visualization.
7. Cytokine-storm gene expression, GO enrichment, scoring, correlations, ridge
   plots, and summary tables.
8. CAR-T, COVID-19, and SLE CellChat input preparation and validation.
9. SLE pDC differential-expression, IFN scoring, dotplot, and pDC/monocyte IFN
   correlation analysis.

Downstream CellChat execution and visualization are maintained in
`scripts/cellchat/`, not in this notebook.

## Notebook 2: myeloid and monocyte analysis

`notebooks/02_myeloid_monocyte_analysis.ipynb`

Major workflow areas:

1. Environment setup, path configuration, processed-object loading, and object
   validation.
2. Myeloid/monocyte annotation inspection.
3. Myeloid UMAP visualization.
4. Cross-disease monocyte subcluster observed/expected analysis.
5. Myeloid cytokine-storm scoring and expression summaries.
6. IL1B, S100A8, and CD16 monocyte functional comparisons.
7. Cross-disease, COVID-19, and SLE DEG/enrichment analyses.
8. Cross-disease and disease-specific monocyte functional-module scoring.
9. SLE IFN-I, IFN/Fc-receptor, and correlation analyses.
10. CAR-T-associated monocyte receptor and stage-specific CS-score analyses.

## Notebook 3: T-lineage and CAR-T analysis

`notebooks/03_t_lineage_cart_analysis.ipynb`

Major workflow areas:

1. Environment setup, path configuration, processed-object loading, and object
   validation.
2. Object inspection and CAR-T/endoT identification.
3. T-cell subcluster and CAR-T visualization.
4. T-lineage and CAR-T cytokine-storm scoring and expression summaries.
5. CAR-T DEG and enrichment comparisons.
6. CAR-T and endoT subcluster dynamics.
7. CAR-T versus endoT functional-state scoring and radial visualization.
8. CD4 and CD8 CAR-T functional-state scoring and radial visualization.

## CellChat scripts

`scripts/cellchat/`

The CellChat workflow is split into runner scripts and downstream-analysis
scripts:

- `run_cellchat_cart.R`
- `analyze_cellchat_cart.R`
- `run_cellchat_covid19.R`
- `analyze_cellchat_covid19.R`
- `run_cellchat_sle.R`
- `analyze_cellchat_sle.R`

Runner scripts consume CellChat input folders exported by
`notebooks/01_global_atlas_analysis.ipynb` and create CellChat `.rds` objects.
Analysis scripts consume those `.rds` objects and generate pathway summaries,
source-data tables, and figure outputs.

## Workflow classification

Metadata harmonization, annotation renaming, downstream filtering, QC
inspection, integration-quality assessment, scoring, DEG, enrichment,
statistical testing, plotting, table export, CellChat input preparation, and
CellChat downstream visualization are treated as downstream analysis steps in
this repository.

Raw sequencing preprocessing, alignment/counting, initial count-matrix
generation, and full upstream integration/batch-correction workflows are outside
the scope of this public code release.
