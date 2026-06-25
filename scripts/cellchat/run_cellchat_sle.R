# Build CellChat objects for the SLE moderate-versus-severe comparison.
#
# Input directories are produced by notebooks/01_global_atlas_analysis.ipynb:
#   outputs/cellchat/sle/input/<group>/
#
# Paths can be overridden with:
#   CELLCHAT_SLE_INPUT_DIR
#   CELLCHAT_SLE_OUTPUT_DIR

suppressPackageStartupMessages({
  library(CellChat)
  library(Matrix)
  library(future)
})

input_dir <- Sys.getenv(
  "CELLCHAT_SLE_INPUT_DIR",
  unset = file.path("outputs", "cellchat", "sle", "input")
)
output_dir <- Sys.getenv(
  "CELLCHAT_SLE_OUTPUT_DIR",
  unset = file.path("outputs", "cellchat", "sle", "output")
)

groups_to_run <- c("SLE_Moderate", "SLE_Severe")
workers <- as.integer(Sys.getenv("CELLCHAT_WORKERS", unset = "4"))

if (!dir.exists(input_dir)) {
  stop("CellChat input directory does not exist: ", input_dir)
}
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

plan(multisession, workers = workers)
options(future.globals.maxSize = 8000 * 1024^2)

run_cellchat_group <- function(group_name) {
  data_dir <- file.path(input_dir, group_name)
  required_files <- file.path(
    data_dir,
    c("expression_matrix.mtx", "genes.csv", "meta.csv")
  )

  if (!dir.exists(data_dir)) {
    stop("Missing input directory for group ", group_name, ": ", data_dir)
  }
  if (any(!file.exists(required_files))) {
    stop(
      "Missing required input file(s) for group ",
      group_name,
      ": ",
      paste(basename(required_files[!file.exists(required_files)]), collapse = ", ")
    )
  }

  counts <- readMM(file.path(data_dir, "expression_matrix.mtx"))
  genes <- read.csv(
    file.path(data_dir, "genes.csv"),
    header = FALSE,
    stringsAsFactors = FALSE
  )
  meta <- read.csv(
    file.path(data_dir, "meta.csv"),
    row.names = 1,
    check.names = FALSE
  )

  if (!"cellchat_anno" %in% colnames(meta)) {
    stop("meta.csv is missing the required cellchat_anno column for ", group_name)
  }

  gene_names <- make.unique(as.character(genes[[1]]))
  if (nrow(counts) == length(gene_names) && ncol(counts) == nrow(meta)) {
    # Matrix already has genes in rows and cells in columns.
  } else if (ncol(counts) == length(gene_names) && nrow(counts) == nrow(meta)) {
    counts <- t(counts)
  } else {
    stop(
      "Matrix dimensions do not match genes.csv and meta.csv for ",
      group_name,
      ". Matrix: ",
      paste(dim(counts), collapse = " x "),
      "; genes: ",
      length(gene_names),
      "; cells: ",
      nrow(meta)
    )
  }

  counts <- as(counts, "dgCMatrix")
  rownames(counts) <- gene_names
  colnames(counts) <- rownames(meta)

  common_cells <- intersect(colnames(counts), rownames(meta))
  if (length(common_cells) == 0) {
    stop("No matching cell identifiers between matrix and metadata for ", group_name)
  }
  counts <- counts[, common_cells, drop = FALSE]
  meta <- meta[common_cells, , drop = FALSE]

  library_size <- Matrix::colSums(counts)
  if (any(library_size <= 0)) {
    stop("Zero-library cells were found in ", group_name)
  }

  norm_counts <- t(t(counts) / library_size) * 10000
  norm_counts@x <- log1p(norm_counts@x)

  cellchat <- createCellChat(
    object = norm_counts,
    meta = meta,
    group.by = "cellchat_anno"
  )
  cellchat@DB <- CellChatDB.human
  cellchat <- subsetData(cellchat)
  cellchat <- identifyOverExpressedGenes(cellchat)
  cellchat <- identifyOverExpressedInteractions(cellchat)
  cellchat <- computeCommunProb(
    cellchat,
    raw.use = TRUE,
    type = "truncatedMean",
    trim = 0.1
  )
  cellchat <- filterCommunication(cellchat, min.cells = 10)
  cellchat <- computeCommunProbPathway(cellchat)
  cellchat <- aggregateNet(cellchat)

  save_path <- file.path(output_dir, paste0("cellchat_", group_name, ".rds"))
  saveRDS(cellchat, file = save_path)
  message("Saved: ", save_path)
}

for (group_name in groups_to_run) {
  message("\nProcessing SLE CellChat group: ", group_name)
  tryCatch(
    run_cellchat_group(group_name),
    error = function(e) {
      stop("CellChat failed for ", group_name, ": ", conditionMessage(e))
    }
  )
}

message("All SLE CellChat groups completed.")
