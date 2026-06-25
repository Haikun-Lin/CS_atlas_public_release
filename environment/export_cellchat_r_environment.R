# Export public software-version records for the R / CellChat environment.
#
# Run this script on the analysis server/environment used to execute the
# CellChat runner and downstream-analysis scripts. The generated files record
# package names and versions without exporting local library paths.

args <- commandArgs(trailingOnly = TRUE)
output_dir <- if (length(args) >= 1) args[[1]] else file.path("environment", "generated")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

key_packages <- data.frame(
  software_or_package = c(
    "R",
    "CellChat",
    "Matrix",
    "future",
    "dplyr",
    "purrr",
    "tibble",
    "ggplot2",
    "pheatmap",
    "RColorBrewer",
    "circlize",
    "scales"
  ),
  package_name = c(
    NA,
    "CellChat",
    "Matrix",
    "future",
    "dplyr",
    "purrr",
    "tibble",
    "ggplot2",
    "pheatmap",
    "RColorBrewer",
    "circlize",
    "scales"
  ),
  language_or_platform = c(
    "R",
    rep("R", 11)
  ),
  used_in = c(
    "CellChat scripts",
    "CellChat runner and downstream-analysis scripts",
    "CellChat runner scripts",
    "CellChat runner scripts",
    "CellChat downstream-analysis scripts",
    "CAR-T CellChat downstream-analysis script",
    "CAR-T CellChat downstream-analysis script",
    "CellChat downstream-analysis scripts",
    "SLE CellChat downstream-analysis script",
    "SLE CellChat downstream-analysis script",
    "CellChat downstream-analysis scripts",
    "CellChat downstream-analysis scripts"
  ),
  purpose = c(
    "R execution runtime",
    "Cell-cell communication inference and visualization",
    "Sparse matrix input handling",
    "Parallel execution configuration",
    "Data manipulation",
    "Functional iteration",
    "Tidy tabular outputs",
    "Figure generation",
    "Heatmap visualization",
    "Color palettes",
    "Circular network visualization",
    "Plot scaling and formatting"
  ),
  stringsAsFactors = FALSE
)

version_or_status <- function(package_name) {
  if (is.na(package_name)) {
    return(as.character(getRversion()))
  }
  if (!requireNamespace(package_name, quietly = TRUE)) {
    return("not_installed")
  }
  as.character(utils::packageVersion(package_name))
}

key_packages$version <- vapply(
  key_packages$package_name,
  version_or_status,
  character(1)
)
key_packages$record_source <- "environment/export_cellchat_r_environment.R"

public_key_packages <- key_packages[
  ,
  c(
    "software_or_package",
    "language_or_platform",
    "version",
    "used_in",
    "purpose",
    "record_source"
  )
]

utils::write.csv(
  public_key_packages,
  file.path(output_dir, "r_key_packages_cellchat.csv"),
  row.names = FALSE,
  quote = TRUE
)
utils::write.csv(
  public_key_packages,
  file.path(output_dir, "methods_software_table_cellchat_r.csv"),
  row.names = FALSE,
  quote = TRUE
)

installed <- as.data.frame(utils::installed.packages()[, c("Package", "Version")])
installed <- installed[order(tolower(installed$Package)), ]
utils::write.csv(
  installed,
  file.path(output_dir, "r_installed_packages.csv"),
  row.names = FALSE,
  quote = TRUE
)

for (package_name in key_packages$package_name[!is.na(key_packages$package_name)]) {
  suppressWarnings(
    suppressPackageStartupMessages(
      require(package_name, character.only = TRUE, quietly = TRUE)
    )
  )
}

session_lines <- c(
  "Privacy note: local library paths and data paths should be reviewed before public release.",
  "",
  capture.output(utils::sessionInfo())
)
writeLines(session_lines, file.path(output_dir, "r_sessionInfo_cellchat.txt"))

message("Wrote R / CellChat environment records to: ", output_dir)
