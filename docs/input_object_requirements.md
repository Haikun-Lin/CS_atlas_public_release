# Private input object requirements

The downstream workflows recorded in this repository start from three processed
AnnData objects. These objects are not distributed through GitHub. The purpose
of this document is to describe the object structure expected by the notebooks
and to make the private input requirements transparent.

## 1. Integrated immune-cell atlas object

Used by `01_global_atlas_analysis.ipynb`.

Expected content includes:

- processed expression values suitable for the downstream operations recorded in the notebook;
- cell-level metadata for sample, disease, stage, severity, major lineage, and subcluster annotations;
- a stored low-dimensional embedding used for atlas visualization;
- raw or full-gene expression access where referenced by the notebook;
- standard QC fields where referenced.

Commonly referenced metadata fields include:

- `sample_id`
- `disease`
- `stage`
- `severity`
- `leiden1_anno`
- `subcluster_anno`
- `n_genes_by_counts`
- `total_counts`
- `pct_counts_mt`

## 2. Myeloid/monocyte object

Used by `02_myeloid_monocyte_analysis.ipynb`.

Expected content includes:

- processed myeloid-lineage expression data;
- myeloid subcluster annotations;
- sample, disease, stage, severity, and group metadata;
- QC fields and an existing visualization embedding where referenced;
- raw or full-gene expression access where referenced.

Commonly referenced fields include:

- `sample_id`
- `disease`
- `stage`
- `severity`
- `myeloid_anno`
- `n_genes_by_counts`
- `total_counts`
- `pct_counts_mt`

## 3. T-lineage/CAR-T object

Used by `03_t_lineage_cart_analysis.ipynb`.

Expected content includes:

- processed T-lineage expression data;
- T-cell subcluster annotations;
- CAR-T versus endogenous-T annotations or sufficient metadata to construct them as recorded;
- sample, disease, stage, severity, group, and sample-type metadata;
- QC fields and an existing visualization embedding where referenced;
- raw or full-gene expression access where referenced.

Commonly referenced fields include:

- `sample_id`
- `disease`
- `stage`
- `severity`
- `group`
- `sample_type`
- `t_anno`
- `CAR-T_anno` (constructed in the notebook from `sample_id`)
- `n_genes_by_counts`
- `pct_counts_mt`

## Object validation recorded in the notebooks

Each notebook records validation checks for its private processed AnnData input.
Those checks document the object structure expected by the downstream workflow:

- object dimensions and unique cell/gene indices;
- required `.obs` metadata columns;
- required embeddings;
- expected disease, stage, and severity categories;
- key annotation fields;
- `.raw` availability where preserved DEG/scoring sections use it.

Notebook 01 also records use of a sample-level metadata workbook containing
unique `sample_id` values and a `sample_type` column.

The processed-object schema reports in `docs/processed_object_schemas/` provide
release-facing summaries of object dimensions, metadata fields, embeddings,
layers/raw status, and major category levels without distributing the AnnData
objects themselves.

## Documented path variables

Expected private input and output path variables are documented directly in the
notebook setup cells, CellChat scripts, and `docs/execution_manifest.md`.

Examples include:

- `ATLAS_H5AD`
- `SAMPLE_METADATA_XLSX`
- `ATLAS_OUTPUT_DIR`
- `MYELOID_H5AD`
- `MYELOID_OUTPUT_DIR`
- `T_LINEAGE_H5AD`
- `T_LINEAGE_OUTPUT_DIR`
- `CELLCHAT_CAR_T_INPUT_DIR`
- `CELLCHAT_CAR_T_OUTPUT_DIR`
- `CELLCHAT_COVID19_INPUT_DIR`
- `CELLCHAT_COVID19_OUTPUT_DIR`
- `CELLCHAT_SLE_INPUT_DIR`
- `CELLCHAT_SLE_OUTPUT_DIR`

The field lists above describe code-level expectations only. They do not assert biological correctness or completeness.
