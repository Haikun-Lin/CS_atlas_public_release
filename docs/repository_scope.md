# Repository scope

## Purpose

This repository documents downstream analytical workflows for a cross-disease
single-cell cytokine storm atlas manuscript. It is organized around three
processed AnnData objects and three corresponding analytical notebooks.

## Included

The repository includes downstream workflow components for:

- metadata harmonization and annotation naming;
- sample, disease, severity, stage, and group mapping;
- processed-object validation;
- QC inspection and mitochondrial-content inspection;
- downstream filtering of processed objects;
- integration-quality assessment, including downsampling and entropy analysis;
- cytokine-storm scoring;
- functional-module scoring;
- differential-expression analysis;
- enrichment analysis;
- statistical testing;
- figure generation;
- supplementary-table export;
- CellChat input preparation;
- downstream visualization and comparison of CellChat results;
- selected organization of derived analysis inputs and outputs.

## Not included

The repository does not include:

- raw sequencing preprocessing;
- read alignment or transcript counting;
- initial count-matrix generation;
- full upstream integration or batch-correction workflows;
- raw datasets;
- distributed processed AnnData objects;
- patient-level private information.

## Primary analytical records

The primary analytical records are:

1. `notebooks/01_global_atlas_analysis.ipynb`
2. `notebooks/02_myeloid_monocyte_analysis.ipynb`
3. `notebooks/03_t_lineage_cart_analysis.ipynb`

Scientific scoring, DEG, enrichment, plotting, and statistical code remain in
the notebooks where those analyses are performed. The project is intentionally
not split into separate generic method folders for every scoring, DEG,
enrichment, plotting, or statistical routine.

Standalone scripts support CellChat execution and downstream CellChat analyses.

## Private processed objects

The processed AnnData objects used by the downstream workflows are not
distributed. Their expected structure is documented through:

- `docs/input_object_requirements.md`
- `docs/processed_object_schemas/`
- `docs/execution_manifest.md`

Manuscript supplementary tables and figures provide release-facing quantitative
summaries, including QC/cell-count summaries, gene-set/module definitions, and
selected expression/statistical results.

## Release policy

Local raw working notebooks and original raw scripts are not part of the public
release. Public-facing files should use repository-relative output defaults and
documented environment-variable names rather than committed server-specific
paths. Path-variable documentation is kept in the notebooks, CellChat scripts,
and execution manifest.
