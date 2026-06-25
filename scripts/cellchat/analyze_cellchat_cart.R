# Downstream CellChat analysis for CAR-T CRS stages.
#
# Run scripts/cellchat/run_cellchat_cart.R first.
# Paths can be overridden with CELLCHAT_CAR_T_OUTPUT_DIR and
# CELLCHAT_CAR_T_ANALYSIS_DIR.

suppressPackageStartupMessages({
  library(CellChat)
  library(dplyr)
  library(purrr)
  library(tibble)
  library(ggplot2)
  library(scales)
})

rds_dir <- Sys.getenv(
  "CELLCHAT_CAR_T_OUTPUT_DIR",
  unset = file.path("outputs", "cellchat", "cart", "output")
)
analysis_dir <- Sys.getenv(
  "CELLCHAT_CAR_T_ANALYSIS_DIR",
  unset = file.path(rds_dir, "analysis")
)
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)

required_conditions <- c("CAR-T_CRS_before", "CAR-T_CRS_pro", "CAR-T_CRS_con")
required_files <- file.path(rds_dir, paste0("cellchat_", required_conditions, ".rds"))
if (any(!file.exists(required_files))) {
  stop(
    "Missing required CAR-T CellChat object(s): ",
    paste(basename(required_files[!file.exists(required_files)]), collapse = ", "),
    ". Run run_cellchat_cart.R first."
  )
}

object_list <- setNames(lapply(required_files, readRDS), required_conditions)
cellchat_list <- list(
  before = object_list[["CAR-T_CRS_before"]],
  pro = object_list[["CAR-T_CRS_pro"]],
  con = object_list[["CAR-T_CRS_con"]]
)

cart_senders <- c(
  "Ta_CD4_MKI67", "Ta_CD8_MKI67", "Tem_CD4_GZMK", "Tem_CD8_GZMK",
  "Tex_CD8_PDCD1", "Tn_CD4_LEF1", "Tcm_CD4_IL7R", "Treg_CD4_FOXP3",
  "Tn_CD8_LEF1", "Tctl_CD8_GZMB", "Tnkl_KLRD1"
)
mono_receivers <- c(
  "Mono_CD14_IL1B", "Mono_CD14_S100A8", "Mono_CD16_LST1"
)

extract_cart_mono_pathways <- function(
    cellchat_obj,
    stage_name,
    senders = cart_senders,
    receivers = mono_receivers) {
  prob_array <- cellchat_obj@netP$prob
  available_senders <- intersect(senders, dimnames(prob_array)[[1]])
  available_receivers <- intersect(receivers, dimnames(prob_array)[[2]])
  pathways <- dimnames(prob_array)[[3]]

  message(stage_name, " senders: ", paste(available_senders, collapse = ", "))
  message(stage_name, " receivers: ", paste(available_receivers, collapse = ", "))

  map_dfr(pathways, function(pathway) {
    pathway_values <- prob_array[
      available_senders,
      available_receivers,
      pathway,
      drop = FALSE
    ]
    tibble(
      stage = stage_name,
      pathway = pathway,
      strength = sum(pathway_values, na.rm = TRUE)
    )
  })
}

df_pathway_raw <- imap_dfr(
  cellchat_list,
  ~ extract_cart_mono_pathways(.x, .y)
)

df_pathway_summary <- df_pathway_raw %>%
  group_by(pathway) %>%
  summarise(
    total_strength = sum(strength, na.rm = TRUE),
    before_strength = sum(strength[stage == "before"], na.rm = TRUE),
    pro_strength = sum(strength[stage == "pro"], na.rm = TRUE),
    con_strength = sum(strength[stage == "con"], na.rm = TRUE),
    before_fraction = before_strength / total_strength,
    pro_fraction = pro_strength / total_strength,
    con_fraction = con_strength / total_strength,
    n_present_stages = sum(c(before_strength, pro_strength, con_strength) > 0),
    dominant_stage = c("before", "pro", "con")[
      which.max(c(before_strength, pro_strength, con_strength))
    ],
    .groups = "drop"
  ) %>%
  filter(total_strength > 0) %>%
  arrange(desc(total_strength))

write.csv(
  df_pathway_raw,
  file.path(analysis_dir, "CAR-T_to_monocyte_pathway_strength_by_stage_raw.csv"),
  row.names = FALSE
)
write.csv(
  df_pathway_summary,
  file.path(
    analysis_dir,
    "CAR-T_to_monocyte_pathway_summary_with_stage_fraction.csv"
  ),
  row.names = FALSE
)

# Key CAR-T-to-monocyte pathways enriched before treatment (Fig. 3F).
pathways_keep <- c("CD40", "CSF", "LT", "TNF", "ICAM")
df_plot <- df_pathway_raw %>%
  filter(pathway %in% pathways_keep) %>%
  group_by(pathway) %>%
  mutate(
    total_strength = sum(strength, na.rm = TRUE),
    fraction = strength / total_strength
  ) %>%
  ungroup() %>%
  mutate(
    stage = factor(stage, levels = c("before", "pro", "con")),
    pathway = factor(pathway, levels = rev(pathways_keep))
  )

p_frac <- ggplot(df_plot, aes(x = fraction, y = pathway, fill = stage)) +
  geom_col(width = 0.75) +
  scale_x_continuous(
    labels = percent_format(accuracy = 1),
    expand = c(0, 0)
  ) +
  labs(
    x = "Fraction of pathway communication strength",
    y = NULL,
    fill = NULL
  ) +
  theme_classic(base_size = 12) +
  theme(
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank(),
    legend.position = "top"
  )

ggsave(
  filename = file.path(
    analysis_dir,
    "CAR-T_to_monocyte_pathway_fraction_barplot.pdf"
  ),
  plot = p_frac,
  width = 6,
  height = 4,
  dpi = 300
)

message("CAR-T downstream CellChat analysis completed: ", analysis_dir)
