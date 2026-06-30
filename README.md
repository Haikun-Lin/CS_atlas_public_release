# Cross-disease single-cell cytokine storm atlas

This repository contains downstream analytical workflow code associated with the
cross-disease single-cell cytokine storm atlas manuscript.

The repository is notebook-centered and object-centered. The notebooks and
scripts document downstream analysis, figure generation, supplementary-table
generation, and CellChat workflows that start from processed AnnData objects.
The processed AnnData objects are not distributed with this repository
because of their file size and the data-use considerations associated with
human single-cell datasets.

## Primary notebooks

- `notebooks/01_global_atlas_analysis.ipynb` - integrated immune-cell atlas,
  global QC and integration assessment, cytokine-storm scoring, global figures
  and tables, CellChat input preparation, and selected pDC and B cell analyses.
- `notebooks/02_myeloid_monocyte_analysis.ipynb` - cross-disease myeloid and
  monocyte analyses, including COVID-19, SLE, and CAR-T-associated analyses.
- `notebooks/03_t_lineage_cart_analysis.ipynb` - T-lineage and CAR-T cohort
  analyses.

The notebooks remain the primary analytical records. Recurrent scoring, DEG,
enrichment, plotting, and statistical code is intentionally retained inside
them. Generated figure outputs were not retained due to upload size limit.

## Repository scope

Included downstream workflows cover:

- metadata harmonization and annotation naming;
- sample, disease, severity, stage, and group mapping;
- processed-object validation;
- QC and mitochondrial-content inspection;
- downstream filtering of processed objects;
- integration-quality assessment;
- cytokine-storm and functional-module scoring;
- differential-expression and enrichment analyses;
- statistical testing;
- figure and supplementary-table generation;
- CellChat input preparation and downstream CellChat result visualization.

The repository does not include raw sequencing preprocessing,
alignment/counting, initial count-matrix generation, raw-data distribution, or
the full upstream integration/batch-correction workflow.

## Public documentation

See:

- `docs/repository_scope.md`
- `docs/execution_manifest.md`
- `docs/input_object_requirements.md`
- `docs/analysis_workflow.md`
- `docs/reproducibility_notes.md`
- `docs/processed_object_schemas/`
- `figure_table_mapping/figure_code_mapping.md`
- `figure_table_mapping/supplementary_table_mapping.md`
- `environment/methods_software_table.csv`

## Data availability and path variables

Large biological data objects are not tracked. The processed AnnData objects
used by the downstream workflows are described through object-schema reports in
`docs/processed_object_schemas/` and through code-level expectations in
`docs/input_object_requirements.md`.

Notebook and script setup cells document the environment-variable names used for
private input locations and generated output locations, for example
`ATLAS_H5AD`, `MYELOID_H5AD`, `T_LINEAGE_H5AD`, and CellChat-specific path
variables. These variables are recorded to make the downstream workflow
structure explicit.

Do not commit patient-level private information, processed AnnData objects,
matrix files, RDS objects, or machine-specific local/server paths.

## Release status

All three public-facing notebooks have undergone manual scientific review and
targeted workflow cleanup. CellChat execution and downstream CellChat analyses
are maintained as standalone scripts under `scripts/cellchat/`.

Scientific thresholds, normalization choices, subcluster exclusions, gene sets,
and output definitions remain analysis-specific and are documented in the
notebooks, mapping files, and manuscript supplementary materials.
