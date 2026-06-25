# Analysis transparency and reproducibility notes

## Current notebook state

The public-facing notebooks use stable repository names and have undergone
manual scientific review plus targeted workflow cleanup. They include
documented path variables, early processed-object validation, and separation of
CellChat execution from notebook-based CellChat input preparation.

The notebooks contain no stored outputs or execution counts. They are downstream
analytical workflow records that start from private processed AnnData objects.
Those objects are not distributed in this repository because of their file size
and the data-use considerations associated with human single-cell datasets.

## Workflow dependencies

The notebooks are organized in section order, and later sections intentionally
depend on variables, objects, categories, and files created earlier in the same
notebook. The setup cells document the environment-variable names used for
private inputs and generated outputs in the original downstream workflow.

Each notebook performs early validation of its processed AnnData input. These
checks cover nonempty and uniquely indexed objects, required metadata columns,
required embeddings, expected disease/stage/severity categories, and key
annotation fields. Notebook 02 additionally requires a populated `.raw` gene
space for preserved DEG and scoring sections. Notebook 03 constructs and
validates `CAR-T_anno` from the approved sample mapping.

## Temporary reconstruction and normalization

Notebook 02 contains downstream DEG blocks that reconstruct temporary AnnData
objects from stored `.raw` data and apply normalization/log transformation
within those temporary objects. This behavior is part of the curated analysis.
Notebooks 01 and 03 operate on their supplied processed objects and do not
cover upstream raw-data preprocessing.

## Names and labels

Repository labels follow the terminology used by the curated analyses. In
notebook 03, `CAR-T` identifies the infused CAR-T population and `endoT`
identifies endogenous T cells; the corresponding annotation column is
`CAR-T_anno`.

Notebook 01 normalizes legacy CAR-T annotation spelling on object loading and
uses `CAR-T_anno` thereafter. Its Table S2d expression summary gives each
sample equal weight, whereas the Fig. 1E heatmap intentionally summarizes all
cells within each group. Both use gene-wise z-scores with `ddof=1`.

`CS_score` and explicitly named scaled-score columns represent distinct
recorded quantities.

## Path variables

Curated workflows use repository-relative output defaults and documented
environment-variable names for private input locations. The expected variables
are listed directly in notebook setup cells, CellChat scripts, and
`docs/execution_manifest.md`.

No real local/server path should be committed.

## CellChat

CellChat workflows include:

- Python preparation/export of expression matrices and metadata;
- standalone R runners that create CellChat objects;
- standalone downstream R visualization and comparison scripts.

Final CellChat scripts are maintained under `scripts/cellchat/`. CAR-T
CellChat path overrides use `CELLCHAT_CAR_T_*` environment variables.

## Repeated workflow blocks

Some repeated analysis blocks are intentional because they support independent
figure or table sections. In notebook 03, the repeated functional-state scoring
workflows separately support CAR-T-versus-endoT and CD4-versus-CD8 CAR-T
comparisons.

## Environment

The compact software/version record is:

- `environment/methods_software_table.csv`

The compact Python package list is:

- `environment/python_requirements_public.txt`

Environment-recording scripts are:

- `environment/export_python_environment.py`
- `environment/export_cellchat_r_environment.R`

## Data and privacy

- Do not commit AnnData, RDS, matrix, sequencing, alignment, or other large
  biological data files.
- Do not commit patient-level private data.
- Review sample identifiers and exported tables before public release.
- Keep local path configuration outside version control.
