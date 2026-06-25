# Downstream CellChat analysis for SLE moderate-versus-severe comparisons.
#
# Run scripts/cellchat/run_cellchat_sle.R first.
# Paths can be overridden with CELLCHAT_SLE_OUTPUT_DIR and
# CELLCHAT_SLE_ANALYSIS_DIR.

suppressPackageStartupMessages({
  library(CellChat)
  library(dplyr)
  library(ggplot2)
  library(pheatmap)
  library(RColorBrewer)
  library(circlize)
})

rds_dir <- Sys.getenv(
  "CELLCHAT_SLE_OUTPUT_DIR",
  unset = file.path("outputs", "cellchat", "sle", "output")
)
analysis_dir <- Sys.getenv(
  "CELLCHAT_SLE_ANALYSIS_DIR",
  unset = file.path(rds_dir, "analysis")
)
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)

required_conditions <- c("SLE_Moderate", "SLE_Severe")
required_files <- file.path(rds_dir, paste0("cellchat_", required_conditions, ".rds"))
if (any(!file.exists(required_files))) {
  stop(
    "Missing required SLE CellChat object(s): ",
    paste(basename(required_files[!file.exists(required_files)]), collapse = ", "),
    ". Run run_cellchat_sle.R first."
  )
}

object_list <- setNames(lapply(required_files, readRDS), required_conditions)
cellchat_moderate <- object_list[["SLE_Moderate"]]
cellchat_severe <- object_list[["SLE_Severe"]]

# Mono_CD16_LST1-skewed pathways in severe SLE (Fig. 5H).
original_sources <- c(
  "Mono_CD14_IL1B", "Mono_CD14_S100A8", "Mono_CD16_LST1"
)
receivers_to_plot <- c(
  "pDC", "CD4_T", "CD8_T", "NK", "Bn_CD19_TCL1A",
  "Plasma_TNFRSF17", "Bm_CD19_CD27", "cDC_CD1C"
)
pathways_to_plot <- c("TNF", "CXCL", "MIF", "ICAM")

df_net <- subsetCommunication(
  cellchat_severe,
  sources.use = original_sources,
  targets.use = receivers_to_plot,
  signaling = pathways_to_plot,
  slot.name = "netP"
)
if (is.null(df_net) || nrow(df_net) == 0) {
  stop("No severe-SLE communications were found for the selected Fig. 5H pathways.")
}

plot_data <- df_net %>%
  mutate(
    source_group = case_when(
      source == "Mono_CD16_LST1" ~ "Mono_CD16_LST1",
      TRUE ~ "CD14_Mono"
    )
  ) %>%
  group_by(pathway_name, source_group) %>%
  summarise(total_prob = sum(prob), .groups = "drop") %>%
  group_by(pathway_name) %>%
  mutate(relative_strength = total_prob / sum(total_prob)) %>%
  ungroup() %>%
  mutate(
    source_group = factor(
      source_group,
      levels = c("Mono_CD16_LST1", "CD14_Mono")
    )
  )

panel_h <- ggplot(
  plot_data,
  aes(y = pathway_name, x = relative_strength, fill = source_group)
) +
  geom_bar(
    stat = "identity",
    position = "stack",
    width = 0.7,
    color = "grey30"
  ) +
  geom_vline(xintercept = 0.5, linetype = "dashed", color = "grey40") +
  scale_fill_manual(
    values = c(Mono_CD16_LST1 = "#A52A2A", CD14_Mono = "#4682B4")
  ) +
  theme_bw() +
  labs(
    title = "Key differential pathways by monocytes",
    subtitle = "(Severe SLE)",
    x = "Relative signaling strength",
    y = NULL,
    fill = NULL
  ) +
  scale_x_continuous(expand = c(0, 0), breaks = c(0, 0.5, 1)) +
  theme(
    panel.grid = element_blank(),
    axis.text.y = element_text(face = "bold", size = 10),
    axis.text.x = element_text(size = 10),
    plot.title = element_text(hjust = 0.5, size = 11, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 10),
    legend.position = "right"
  )

ggsave(
  file.path(analysis_dir, "CD16_vs_CD14_outgoing_signaling.pdf"),
  plot = panel_h,
  width = 5,
  height = 4
)

# Compute pathway centrality once for the incoming and outgoing analyses.
cellchat_moderate <- netAnalysis_computeCentrality(
  cellchat_moderate,
  slot.name = "netP"
)
cellchat_severe <- netAnalysis_computeCentrality(
  cellchat_severe,
  slot.name = "netP"
)
target_mono <- c(
  "Mono_CD14_IL1B", "Mono_CD14_S100A8", "Mono_CD16_LST1"
)

get_centrality_matrix <- function(cellchat_obj, targets, direction) {
  centrality <- cellchat_obj@netP$centr
  pathways <- names(centrality)
  matrix_out <- matrix(
    0,
    nrow = length(pathways),
    ncol = length(targets),
    dimnames = list(pathways, targets)
  )

  for (pathway in pathways) {
    values <- centrality[[pathway]][[direction]]
    valid_targets <- intersect(targets, names(values))
    if (length(valid_targets) > 0) {
      matrix_out[pathway, valid_targets] <- values[valid_targets]
    }
  }
  matrix_out
}

align_moderate_matrix <- function(
    moderate_matrix,
    displayed_pathways,
    target_cells) {
  aligned <- matrix(
    0,
    nrow = length(displayed_pathways),
    ncol = length(target_cells),
    dimnames = list(displayed_pathways, target_cells)
  )
  shared_pathways <- intersect(displayed_pathways, rownames(moderate_matrix))
  shared_cells <- intersect(target_cells, colnames(moderate_matrix))
  aligned[shared_pathways, shared_cells] <-
    moderate_matrix[shared_pathways, shared_cells, drop = FALSE]
  aligned
}

centrality_to_source_table <- function(
    moderate_matrix,
    severe_matrix,
    direction_label) {
  displayed_pathways <- rownames(severe_matrix)
  moderate_aligned <- align_moderate_matrix(
    moderate_matrix,
    displayed_pathways,
    target_mono
  )
  severe_aligned <- severe_matrix[
    displayed_pathways,
    target_mono,
    drop = FALSE
  ]

  expand.grid(
    Pathway_name = displayed_pathways,
    Monocyte_subcluster = target_mono,
    stringsAsFactors = FALSE
  ) %>%
    mutate(
      Direction = direction_label,
      Severe_signaling_strength = mapply(
        function(pathway, cell) severe_aligned[pathway, cell],
        Pathway_name,
        Monocyte_subcluster
      ),
      Moderate_signaling_strength = mapply(
        function(pathway, cell) moderate_aligned[pathway, cell],
        Pathway_name,
        Monocyte_subcluster
      )
    ) %>%
    select(
      Pathway_name,
      Direction,
      Monocyte_subcluster,
      Severe_signaling_strength,
      Moderate_signaling_strength
    )
}

# Incoming signaling pathways to monocyte subclusters (Fig. S5H).
incoming_moderate <- get_centrality_matrix(
  cellchat_moderate,
  target_mono,
  "indeg"
)
incoming_severe <- get_centrality_matrix(
  cellchat_severe,
  target_mono,
  "indeg"
)
incoming_moderate <- incoming_moderate[
  rowSums(incoming_moderate) > 0,
  ,
  drop = FALSE
]
incoming_severe <- incoming_severe[
  rowSums(incoming_severe) > 0,
  ,
  drop = FALSE
]

incoming_pathways <- c(
  "IL1", "IL6", "TNF", "IFN-II", "CCL", "CD23",
  "LAIR1", "BTLA", "CD48", "ICAM", "SELPLG", "JAM"
)
incoming_use <- intersect(incoming_pathways, rownames(incoming_severe))
incoming_severe_sub <- incoming_severe[incoming_use, , drop = FALSE]
incoming_severe_sub <- incoming_severe_sub[
  rowSums(incoming_severe_sub) > 0,
  ,
  drop = FALSE
]
if (nrow(incoming_severe_sub) == 0) {
  stop("None of the selected incoming pathways are available in severe SLE.")
}

pdf(file.path(analysis_dir, "monocyte_incoming_pathways.pdf"), width = 6, height = 8)
pheatmap(
  incoming_severe_sub,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = FALSE,
  color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdBu")))(100),
  na_col = "white",
  fontsize_row = 8,
  fontsize_col = 10,
  angle_col = 45
)
dev.off()

incoming_source_df <- centrality_to_source_table(
  incoming_moderate,
  incoming_severe_sub,
  "incoming"
)
write.csv(
  incoming_source_df,
  file.path(
    analysis_dir,
    "FigS5H_incoming_pathway_signaling_strength_source_data.csv"
  ),
  row.names = FALSE
)

# Outgoing signaling pathways from monocyte subclusters (Fig. S5H).
outgoing_moderate <- get_centrality_matrix(
  cellchat_moderate,
  target_mono,
  "outdeg"
)
outgoing_severe <- get_centrality_matrix(
  cellchat_severe,
  target_mono,
  "outdeg"
)
outgoing_moderate <- outgoing_moderate[
  rowSums(outgoing_moderate) > 0,
  ,
  drop = FALSE
]
outgoing_severe <- outgoing_severe[
  rowSums(outgoing_severe) > 0,
  ,
  drop = FALSE
]

write.csv(
  outgoing_moderate,
  file.path(analysis_dir, "outgoing_centrality_Moderate.csv")
)
write.csv(
  outgoing_severe,
  file.path(analysis_dir, "outgoing_centrality_Severe.csv")
)

outgoing_pathways <- c(
  "MIF", "CXCL", "CD86", "IL1", "TNF", "CD48",
  "LAIR1", "CCL", "BAFF", "ICAM"
)
outgoing_use <- intersect(outgoing_pathways, rownames(outgoing_severe))
outgoing_severe_sub <- outgoing_severe[outgoing_use, , drop = FALSE]
outgoing_severe_sub <- outgoing_severe_sub[
  rowSums(outgoing_severe_sub) > 0,
  ,
  drop = FALSE
]
if (nrow(outgoing_severe_sub) == 0) {
  stop("None of the selected outgoing pathways are available in severe SLE.")
}

pdf(file.path(analysis_dir, "monocyte_outgoing_pathways.pdf"), width = 6, height = 8)
pheatmap(
  outgoing_severe_sub,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = FALSE,
  color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdBu")))(100),
  na_col = "white",
  fontsize_row = 8,
  fontsize_col = 10,
  angle_col = 45
)
dev.off()

outgoing_source_df <- centrality_to_source_table(
  outgoing_moderate,
  outgoing_severe_sub,
  "outgoing"
)
write.csv(
  outgoing_source_df,
  file.path(
    analysis_dir,
    "FigS5H_outgoing_pathway_signaling_strength_source_data.csv"
  ),
  row.names = FALSE
)

# IL6 chord plot from Bn_CD19_TCL1A in severe SLE (Fig. S5I).
pathways_show <- "IL6"
target_cells <- c(
  "Mono_CD14_IL1B", "Mono_CD14_S100A8", "Plasma_TNFRSF17",
  "pDC", "cDC_CD1C"
)
sender_cells <- "Bn_CD19_TCL1A"
all_nodes <- c(sender_cells, target_cells)

if (!pathways_show %in% dimnames(cellchat_severe@netP$prob)[[3]]) {
  stop("IL6 is not available in the severe-SLE pathway-level network.")
}

il6_matrix <- cellchat_severe@netP$prob[, , pathways_show, drop = FALSE]
if (length(dim(il6_matrix)) == 3) {
  il6_matrix <- il6_matrix[, , 1]
}
df_edges <- as.data.frame(as.table(il6_matrix))
colnames(df_edges) <- c("Source", "Target", "Prob")
df_edges$Pathway <- pathways_show

df_norm <- df_edges %>%
  filter(
    Target %in% target_cells,
    Source %in% sender_cells,
    Prob > 0
  ) %>%
  group_by(Pathway) %>%
  mutate(Plot_weight = Prob / max(Prob)) %>%
  ungroup()
if (nrow(df_norm) == 0) {
  stop("No IL6 edges were found from Bn_CD19_TCL1A to the selected target cells.")
}

df_dummy <- data.frame(
  Source = all_nodes,
  Target = all_nodes,
  Prob = 0,
  Pathway = "Dummy",
  Plot_weight = 3
)
df_plot <- bind_rows(df_norm, df_dummy)

pathway_cols <- c(IL6 = "#D71B1B", Dummy = "#00000000")
node_cols <- setNames(rep("grey80", length(all_nodes)), all_nodes)
node_cols["Mono_CD14_IL1B"] <- "#457B9D"
node_cols["Mono_CD14_S100A8"] <- "#F4A261"
node_cols["Bn_CD19_TCL1A"] <- "#E63946"
node_cols["Plasma_TNFRSF17"] <- "#2A9D8F"
node_cols["pDC"] <- "#E9C46A"
node_cols["cDC_CD1C"] <- "#264653"

arrow_directions <- ifelse(df_plot$Pathway == "IL6", 1, 0)
link_transparency <- ifelse(df_plot$Pathway == "IL6", 0.4, 1)

pdf(
  file.path(analysis_dir, "chord_diagram_incoming_monocytes_severe_SLE.pdf"),
  width = 10,
  height = 8
)
circos.clear()
circos.par(gap.after = 5)
chordDiagram(
  x = df_plot[, c("Source", "Target", "Plot_weight")],
  order = all_nodes,
  grid.col = node_cols,
  col = pathway_cols[df_plot$Pathway],
  transparency = link_transparency,
  directional = arrow_directions,
  direction.type = "arrows",
  link.arr.type = "triangle",
  link.arr.length = 0.15,
  link.arr.width = 0.15,
  annotationTrack = "grid",
  preAllocateTracks = list(track.height = max(strwidth(all_nodes)))
)
circos.track(track.index = 1, panel.fun = function(x, y) {
  circos.text(
    CELL_META$xcenter,
    CELL_META$ylim[1] + 0.5,
    CELL_META$sector.index,
    facing = "clockwise",
    niceFacing = TRUE,
    adj = c(0, 0.5),
    cex = 0.8
  )
}, bg.border = NA)
legend(
  "right",
  legend = "IL6",
  fill = pathway_cols["IL6"],
  title = "Pathway",
  border = NA,
  bty = "n",
  cex = 0.9
)
dev.off()

message("SLE downstream CellChat analysis completed: ", analysis_dir)
