# Environment and software-version records

This folder records the Python and R software environment used for the
downstream atlas notebooks and CellChat scripts.

## Public-release files

- `methods_software_table.csv` - combined Python and R software table suitable
  for Methods reporting or a supplementary software-version table.
- `python_requirements_public.txt` - compact version-pinned Python package list
  for packages directly used by the public notebooks.
- `export_python_environment.py` - script used to generate Python environment
  records in the original analysis environment.
- `export_cellchat_r_environment.R` - script used to generate R/CellChat
  environment records in the original analysis environment.
- `README.md` - this file.

The compact table is the preferred public-facing record. Full installed-package
lists and full session-info files are intentionally not included in this release
folder because they are verbose and can contain local environment details.

## Combined Methods software table

The public-facing combined table is:

```text
methods_software_table.csv
```

It uses these columns:

- `software_or_package`
- `language_or_platform`
- `version`
- `used_in`
- `purpose`
- `record_source`

This table is the preferred compact source for manuscript Methods reporting.

## Python package list

The compact Python package list is:

```text
python_requirements_public.txt
```

It records installable Python packages directly used by the public notebooks.
Python standard-library modules are documented in `methods_software_table.csv`
but are not included in the requirements file.
