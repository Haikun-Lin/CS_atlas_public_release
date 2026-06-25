"""Export public software-version records for the Python notebook environment.

Run this script on the analysis server/environment used to execute the public
notebooks. It intentionally records package names and versions without exporting
local installation paths, user names, data paths, or processed AnnData objects.
"""

from __future__ import annotations

import argparse
import csv
import importlib
import importlib.metadata as metadata
import json
import platform
import sys
from datetime import datetime
from pathlib import Path


KEY_PACKAGES = [
    {
        "software_or_package": "Python",
        "distribution_name": None,
        "import_name": None,
        "language_or_platform": "Python",
        "used_in": "All Python notebooks",
        "purpose": "Notebook execution runtime",
    },
    {
        "software_or_package": "Jupyter/IPython",
        "distribution_name": "ipython",
        "import_name": "IPython",
        "language_or_platform": "Python",
        "used_in": "All Python notebooks",
        "purpose": "Interactive notebook execution",
    },
    {
        "software_or_package": "Python standard library",
        "distribution_name": None,
        "import_name": None,
        "language_or_platform": "Python standard library",
        "used_in": "Notebook 01",
        "purpose": (
            "Runtime logging, timestamps, elapsed-time measurement, and "
            "majority-lineage counting with time, datetime, and collections"
        ),
    },
    {
        "software_or_package": "Scanpy",
        "distribution_name": "scanpy",
        "import_name": "scanpy",
        "language_or_platform": "Python",
        "used_in": "Notebooks 01-03",
        "purpose": "Single-cell AnnData analysis and plotting",
    },
    {
        "software_or_package": "AnnData",
        "distribution_name": "anndata",
        "import_name": "anndata",
        "language_or_platform": "Python",
        "used_in": "Notebooks 01-03",
        "purpose": "Processed single-cell object representation",
    },
    {
        "software_or_package": "pandas",
        "distribution_name": "pandas",
        "import_name": "pandas",
        "language_or_platform": "Python",
        "used_in": "Notebooks 01-03",
        "purpose": "Tabular data handling and export",
    },
    {
        "software_or_package": "NumPy",
        "distribution_name": "numpy",
        "import_name": "numpy",
        "language_or_platform": "Python",
        "used_in": "Notebooks 01-03",
        "purpose": "Numerical calculations and random sampling",
    },
    {
        "software_or_package": "SciPy",
        "distribution_name": "scipy",
        "import_name": "scipy",
        "language_or_platform": "Python",
        "used_in": "Notebooks 01-02 and CellChat input export",
        "purpose": "Sparse matrices, statistics, and Matrix Market export",
    },
    {
        "software_or_package": "Matplotlib",
        "distribution_name": "matplotlib",
        "import_name": "matplotlib",
        "language_or_platform": "Python",
        "used_in": "Notebooks 01-03",
        "purpose": "Figure generation",
    },
    {
        "software_or_package": "Seaborn",
        "distribution_name": "seaborn",
        "import_name": "seaborn",
        "language_or_platform": "Python",
        "used_in": "Notebooks 01-03",
        "purpose": "Statistical visualization",
    },
    {
        "software_or_package": "GSEApy",
        "distribution_name": "gseapy",
        "import_name": "gseapy",
        "language_or_platform": "Python",
        "used_in": "Notebooks 01-03",
        "purpose": "Gene-set and GO enrichment analyses",
    },
    {
        "software_or_package": "Plotly",
        "distribution_name": "plotly",
        "import_name": "plotly",
        "language_or_platform": "Python",
        "used_in": "Notebook 01",
        "purpose": "Sankey and interactive-style figure construction",
    },
    {
        "software_or_package": "OpenPyXL",
        "distribution_name": "openpyxl",
        "import_name": "openpyxl",
        "language_or_platform": "Python",
        "used_in": "Notebook 01",
        "purpose": "Excel supplementary-table formatting",
    },
    {
        "software_or_package": "rpy2",
        "distribution_name": "rpy2",
        "import_name": "rpy2",
        "language_or_platform": "Python/R bridge",
        "used_in": "Notebook 02",
        "purpose": "Notebook R bridge used by preserved analysis sections",
    },
    {
        "software_or_package": "adjustText",
        "distribution_name": "adjustText",
        "import_name": "adjustText",
        "language_or_platform": "Python",
        "used_in": "Notebooks 02-03",
        "purpose": "Non-overlapping text labels in plots",
    },
]


def package_version(distribution_name: str | None, import_name: str | None) -> str:
    if distribution_name is None:
        return platform.python_version()

    try:
        return metadata.version(distribution_name)
    except metadata.PackageNotFoundError:
        pass

    if import_name:
        try:
            module = importlib.import_module(import_name)
            return str(getattr(module, "__version__", "version_not_reported"))
        except Exception:
            return "not_installed_or_not_importable"

    return "not_installed"


def installed_distributions() -> list[dict[str, str]]:
    rows = []
    for dist in metadata.distributions():
        name = dist.metadata.get("Name", dist.metadata.get("Summary", "unknown"))
        rows.append({"package": str(name), "version": str(dist.version)})
    return sorted(rows, key=lambda row: row["package"].lower())


def write_csv(path: Path, rows: list[dict[str, str]], fieldnames: list[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        default="environment/generated",
        help="Directory where environment records will be written.",
    )
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    key_rows = []
    for package in KEY_PACKAGES:
        version = package_version(
            package["distribution_name"], package["import_name"]
        )
        key_rows.append(
            {
                "software_or_package": package["software_or_package"],
                "language_or_platform": package["language_or_platform"],
                "version": version,
                "used_in": package["used_in"],
                "purpose": package["purpose"],
                "record_source": "environment/export_python_environment.py",
            }
        )

    write_csv(
        output_dir / "python_key_packages.csv",
        key_rows,
        [
            "software_or_package",
            "language_or_platform",
            "version",
            "used_in",
            "purpose",
            "record_source",
        ],
    )
    write_csv(
        output_dir / "methods_software_table_python.csv",
        key_rows,
        [
            "software_or_package",
            "language_or_platform",
            "version",
            "used_in",
            "purpose",
            "record_source",
        ],
    )

    installed_rows = installed_distributions()
    write_csv(
        output_dir / "python_installed_packages.csv",
        installed_rows,
        ["package", "version"],
    )

    package_by_software = {
        package["software_or_package"]: package
        for package in KEY_PACKAGES
    }
    requirements_rows = [
        row for row in key_rows
        if package_by_software[row["software_or_package"]]["distribution_name"] is not None
        and row["software_or_package"] != "Jupyter/IPython"
        and row["version"] not in {"not_installed", "not_installed_or_not_importable"}
    ]
    with (output_dir / "python_requirements_public.txt").open(
        "w", encoding="utf-8"
    ) as handle:
        for row in requirements_rows:
            package_name = package_by_software[row["software_or_package"]]["distribution_name"]
            handle.write(f"{package_name}=={row['version']}\n")

    session_info = {
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "privacy_note": (
            "Local executable paths, package installation paths, user names, "
            "and data paths are intentionally omitted."
        ),
        "python": {
            "version": platform.python_version(),
            "implementation": platform.python_implementation(),
            "compiler": platform.python_compiler(),
            "executable_basename": Path(sys.executable).name,
        },
        "platform": {
            "system": platform.system(),
            "release": platform.release(),
            "machine": platform.machine(),
            "processor": platform.processor(),
        },
        "key_packages": key_rows,
        "n_installed_distributions": len(installed_rows),
    }
    with (output_dir / "python_session_info.json").open(
        "w", encoding="utf-8"
    ) as handle:
        json.dump(session_info, handle, indent=2, ensure_ascii=False)

    print(f"Wrote Python environment records to: {output_dir}")


if __name__ == "__main__":
    main()
