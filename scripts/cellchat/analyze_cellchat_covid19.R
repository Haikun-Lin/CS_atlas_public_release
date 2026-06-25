# Downstream CellChat analysis for COVID-19 progression severity.
#
# Run scripts/cellchat/run_cellchat_covid19.R first.
# Paths can be overridden with CELLCHAT_COVID19_OUTPUT_DIR and
# CELLCHAT_COVID19_ANALYSIS_DIR.

suppressPackageStartupMessages({
  library(CellChat)
  library(dplyr)
  library(ggplot2)
})

rds_dir <- Sys.getenv(
  "CELLCHAT_COVID19_OUTPUT_DIR",
  unset = file.path("outputs", "cellchat", "covid19", "output")
)
analysis_dir <- Sys.getenv(
  "CELLCHAT_COVID19_ANALYSIS_DIR",
  unset = file.path(rds_dir, "analysis")
)
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)

required_conditions <- c("COVID19_pro_Moderate", "COVID19_pro_Severe")
required_files <- file.path(rds_dir, paste0("cellchat_", required_conditions, ".rds"))
if (any(!file.exists(required_files))) {
  stop(
    "Missing required COVID-19 CellChat object(s): ",
    paste(basename(required_files[!file.exists(required_files)]), collapse = ", "),
    ". Run run_cellchat_covid19.R first."
  )
}

object_list <- setNames(lapply(required_files, readRDS), required_conditions)
cellchat_moderate <- object_list[["COVID19_pro_Moderate"]]
cellchat_severe <- object_list[["COVID19_pro_Severe"]]
merged <- mergeCellChat(
  list(Moderate = cellchat_moderate, Severe = cellchat_severe),
  add.names = c("Moderate", "Severe")
)

# Monocyte-to-lymphocyte signaling strength comparison (Fig. 4F).
mono <- c("Mono_CD14_IL1B", "Mono_CD14_S100A8")
lymph <- c("CD4_T", "CD8_T", "NK", "B")

valid_idents <- function(cellchat_obj, groups) {
  intersect(groups, levels(cellchat_obj@idents))
}

sum_prob_by <- function(communication_df, group_col) {
  if (is.null(communication_df) || nrow(communication_df) == 0) {
    return(data.frame())
  }
  summary_df <- communication_df %>%
    group_by(.data[[group_col]]) %>%
    summarise(prob_sum = sum(prob, na.rm = TRUE), .groups = "drop")
  names(summary_df)[names(summary_df) == group_col] <- "target"
  summary_df
}

get_mono_to_lymph_strength <- function(cellchat_obj, condition_name) {
  mono_use <- valid_idents(cellchat_obj, mono)
  lymph_use <- valid_idents(cellchat_obj, lymph)

  if (length(mono_use) == 0 || length(lymph_use) == 0) {
    return(data.frame(
      target = factor(lymph, levels = lymph),
      mono_to_lymph = 0,
      condition = condition_name
    ))
  }

  communication_df <- subsetCommunication(
    cellchat_obj,
    sources.use = mono_use,
    targets.use = lymph_use
  )
  strength_df <- sum_prob_by(communication_df, "target") %>%
    rename(mono_to_lymph = prob_sum)

  right_join(strength_df, data.frame(target = lymph), by = "target") %>%
    mutate(
      mono_to_lymph = ifelse(is.na(mono_to_lymph), 0, mono_to_lymph),
      condition = condition_name,
      target = factor(target, levels = lymph)
    ) %>%
    arrange(target)
}

plot_df <- bind_rows(
  get_mono_to_lymph_strength(cellchat_moderate, "Moderate"),
  get_mono_to_lymph_strength(cellchat_severe, "Severe")
) %>%
  mutate(condition = factor(condition, levels = c("Moderate", "Severe")))

p_strength <- ggplot(
  plot_df,
  aes(x = target, y = mono_to_lymph, fill = condition)
) +
  geom_col(position = position_dodge(width = 0.75), width = 0.65) +
  scale_fill_manual(values = c(Moderate = "steelblue", Severe = "firebrick")) +
  labs(
    x = "Lymphocyte subcluster",
    y = "Monocyte -> lymphocyte interaction strength (sum of probabilities)",
    fill = "Condition"
  ) +
  theme_bw(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1, face = "bold"),
    legend.position = "right"
  )

ggsave(
  file.path(analysis_dir, "mono_to_lymph_interaction_strength_M_vs_S.pdf"),
  plot = p_strength,
  width = 8,
  height = 5
)
write.csv(
  plot_df,
  file.path(analysis_dir, "mono_to_lymph_interaction_strength_M_vs_S.csv"),
  row.names = FALSE
)

# Key monocyte-participating signaling pathways (Fig. 4G).
all_interacting_cells <- c(
  "Mono_CD14_S100A8", "Mono_CD14_IL1B",
  "CD4_T", "CD8_T", "NK", "B", "Plasma"
)
fig4g_pathways <- c("MHC-II", "CD86", "ICAM", "IL1", "TNF")
fig4g_plot <- rankNet(
  merged,
  mode = "comparison",
  stacked = TRUE,
  do.stat = TRUE,
  sources.use = all_interacting_cells,
  targets.use = all_interacting_cells,
  signaling = fig4g_pathways
)
ggsave(
  file.path(
    analysis_dir,
    "CellChat_Significant_LR_Interactions_Moderate_vs_Severe.pdf"
  ),
  plot = fig4g_plot,
  width = 10,
  height = 8
)

# Key monocyte-to-lymphocyte signaling pathways (Fig. S4E).
figs4e_pathways <- c(
  "MHC-II", "MHC-I", "CD86", "CD40", "ICAM", "BAFF", "CD48", "SEMA4"
)

get_pathway_flow <- function(cellchat_obj, pathways) {
  available_pathways <- intersect(pathways, cellchat_obj@netP$pathways)
  if (length(available_pathways) == 0) {
    return(data.frame(pathway_name = character(), info_flow = numeric()))
  }
  data.frame(
    pathway_name = available_pathways,
    info_flow = vapply(
      available_pathways,
      function(pathway) sum(cellchat_obj@netP$prob[, , pathway], na.rm = TRUE),
      numeric(1)
    ),
    stringsAsFactors = FALSE
  )
}

flow_moderate <- get_pathway_flow(cellchat_moderate, figs4e_pathways)
flow_severe <- get_pathway_flow(cellchat_severe, figs4e_pathways)
direction_df <- merge(
  flow_moderate,
  flow_severe,
  by = "pathway_name",
  all = TRUE,
  suffixes = c("_Moderate", "_Severe")
)
direction_df$info_flow_Moderate[is.na(direction_df$info_flow_Moderate)] <- 0
direction_df$info_flow_Severe[is.na(direction_df$info_flow_Severe)] <- 0
direction_df$weight_diff <-
  direction_df$info_flow_Severe - direction_df$info_flow_Moderate
direction_df$direction <- ifelse(
  direction_df$weight_diff > 0,
  "Severe > Moderate",
  ifelse(direction_df$weight_diff < 0, "Moderate > Severe", "Equal")
)
direction_df$pathway_name <- factor(
  direction_df$pathway_name,
  levels = figs4e_pathways
)
direction_df <- direction_df[order(direction_df$pathway_name), ]
direction_df$pathway_name <- as.character(direction_df$pathway_name)

write.csv(
  direction_df,
  file.path(analysis_dir, "mono_to_lymph_pathway_information_flow_M_vs_S.csv"),
  row.names = FALSE
)

figs4e_plot <- rankNet(
  merged,
  mode = "comparison",
  comparison = c(1, 2),
  stacked = TRUE,
  do.stat = TRUE,
  sources.use = mono,
  targets.use = lymph
)
ggsave(
  file.path(analysis_dir, "rankNet_mono_to_lymph_M_vs_S.pdf"),
  plot = figs4e_plot,
  width = 10,
  height = 6
)

message("COVID-19 downstream CellChat analysis completed: ", analysis_dir)
