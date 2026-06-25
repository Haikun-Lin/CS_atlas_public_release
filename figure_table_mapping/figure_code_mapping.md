# Figure code mapping

This file maps notebook/script sections to figure-oriented outputs recorded in
the current curated code. Manuscript panel assignments are included where they
are explicitly tracked in repository documentation; otherwise the table records
the exact output files and analysis role without assigning a manuscript panel.

## Global atlas notebook

`notebooks/01_global_atlas_analysis.ipynb`

| Notebook section | Recorded output(s) | Manuscript/use mapping |
|---|---|---|
| Atlas composition Sankey | `sankey.pdf` | Fig. 1B |
| Group cell-count visualization | `group_cell_counts_lollipop_log10.pdf` | Fig. S1F |
| Major-lineage UMAP | `UMAP_major_celltype.png` | Global atlas overview |
| Subcluster UMAP | `UMAP_subclusters.png` | Fig. 1C |
| CAR-T overlay UMAP | `UMAP_CAR-T_highlight.png` | Fig. S1E |
| Disease downsampling | `UMAP_downsampled_by_disease.png` | Fig. S1D |
| Mixing entropy | `UMAP_mixing_entropy.png` | Fig. S1D |
| Severity downsampling | `UMAP_downsampled_by_severity.png` | Fig. S1G |
| Stage downsampling | `UMAP_downsampled_by_stage.png` | Fig. S1G |
| Subcluster marker calculation and visualization | `Table_S1c_top50_subcluster_marker_genes.xlsx`, `Table_S1c_top50_subcluster_marker_genes.csv`, `Table_S1c_subcluster_marker_validation_summary.csv`, `subcluster_marker_matrixplot.pdf` | Table S1c; Fig. S1I |
| CS expression heatmap | `CS_gene_expression_heatmap.pdf` | Fig. 1E |
| CS expression dotplot | `CS_Genes_Dotplot_Resized.pdf` | Fig. S1J |
| Global CS-score UMAP | `CS_score_major.pdf` | Fig. S1H |
| Disease-specific monocyte/non-myeloid correlations | `CS_Correlation_{disease_name}_Monocyte_vs_NonMyeloid.pdf` | Fig. 2D |
| CS-score ridge plot | `RidgePlot_CS_score_by_group_celltype.pdf` | Fig. 2A |
| pDC IFN dotplot | `pDC_IFN_genes_dotplot_SLE.pdf` | Fig. S5E |
| pDC/monocyte IFN correlation | `pDC_vs_Monocyte_IFN_correlation_by_group.pdf` | Fig. 5E |
| IL6 expr by B cells across groups | `IL6_subcluster_group_heatmap.pdf` | Fig. S5J |
| CellChat input preparation | CellChat `expression_matrix.mtx`, `genes.csv`, `meta.csv`, and `CellChat_input_export_summary.csv` | Input for standalone CellChat scripts |

## Myeloid and monocyte notebook

`notebooks/02_myeloid_monocyte_analysis.ipynb`

| Notebook section | Recorded output(s) | Manuscript/use mapping |
|---|---|---|
| Myeloid annotation UMAP | `Myeloid_subclusters_umap.pdf` | Fig. 2B |
| Disease-specific myeloid UMAPs | `Myeloid_subclusters_umap_{disease_name}.pdf` | Fig. S2A |
| Cross-disease monocyte subcluster Ro/e | `myeloid_subcluster_RoE_heatmap.pdf` | Fig. 2E |
| Myeloid CS scores across groups | `Myeloid_CS_score_dotplot_rawCS.pdf` | Fig. 2C |
| IL1B/S100A8/CD16 functional module genes | `IL1B_S100A8_CD16_functional_module_genes.pdf` | Fig. S2F |
| Global monocyte DEG comparison | `IL1B_S100A8_CD16LST1_DEGs.pdf` | Fig. 2F |
| Global monocyte GO enrichment | `il1b_go_up.pdf`, `s100a8_go_up.pdf`, `cd16_go_up.pdf` | Fig. 2G |
| Global monocyte KEGG enrichment | `il1b_kegg_up.pdf`, `s100a8_kegg_up.pdf`, `cd16_kegg_up.pdf` | Fig. S2E |
| COVID-19 DEG comparison | `pro_vs_con_vs_S_vs_M_DEGs.pdf` | Fig.4D  |
| COVID-19 progression GO enrichment | `covid19_disease_go_up.pdf` | Fig. S4B |
| COVID-19 severity GO enrichment | `covid19_severity_go_up.pdf` | Fig. S4C |
| SLE DEG comparison | `SLE_DEGs.pdf` | Fig. S5A |
| SLE GO enrichment | `sle_up_go.pdf`, `ssle_up_go.pdf` | Fig. 5A |
| Severe SLE CD16 monocyte DEG | `SLE_Severe_Mono_CD16_LST1_vs_Others_DEGs.pdf` | Fig. S5G |
| Severe SLE CD16 monocyte GO enrichment | `cd16_up_go.pdf` | Fig. 5G |
| COVID-19 monocyte CS-score ridge plot | `RidgePlot_CS_score_scaled_COVID.pdf` | Fig. 4C |
| COVID-19 functional-module ridge plots | `RidgePlot_{score_col}.pdf` | Fig. 4C |
| COVID-19 functional-module genes | `COVID19_functional_module_genes.pdf` | Fig. S4D |
| Module correlation clustermap | `Corr_All_Modules_Clustermap.pdf` | Monocyte module correlation reference |
| Immunoparalysis versus CS score | `Immunoparalysis_vs_CS_score_centroids.pdf` | Fig. 4E |
| Emergency myelopoiesis versus immunoparalysis | `sample_level_Emergency_vs_Immunoparalysis.pdf` | Fig. 4B |
| SLE severe monocyte IFN-I dotplot | `SLE_Severe_Monocyte_IFN_I_Dotplot.pdf` | Fig. S5F |
| SLE versus COVID-19 IFN genes | `SLE_vs_COVID19_IFN_genes_clustermap.pdf` | Fig. S5C |
| IFN-I gene dotplot | `IFN_I_genes_group.pdf` | Fig. S5B |
| IFN-I versus CS-score correlations | `All_diseases_IFN_I_vs_CS_correlation_panels.pdf` | Fig. 5C, Fig. S5D |
| SLE severe monocyte marker dotplot | `SLE_Severe_Monocyte_Marker_Dotplot.pdf` | Fig. 5F |
| CAR-T monocyte receptor score | `CAR-T_CRS_before_monocyte_receptor_score.pdf` | Fig. 3G |
| CAR-T monocyte receptor genes | `CAR-T_CRS_before_monocyte_receptor_genes_dotplot.pdf` | Fig. 3H |
| Monocyte CS score across CRS stages | `monocyte_CS_score_ridgeplot.pdf`, `monocyte_CS_score_ridgeplot.png` | Fig. S3I |

## T-lineage and CAR-T notebook

`notebooks/03_t_lineage_cart_analysis.ipynb`

| Notebook section | Recorded output(s) | Analysis role |
|---|---|---|
| T-cell subcluster UMAP | Scanpy-saved `_t.png` output | Fig. S3A |
| CAR-T identification UMAP | `UMAP_CAR-T.png` | Fig. S3B |
| T-cell CS score across groups | `CS_score_per_sample_selected_groups.xlsx` | Source table for Fig. 3A |
| CAR-T versus endoT CS score | `CS_score_CAR-T_vs_endoT_matched.xlsx` | Source table for Fig. 3B |
| CAR-T versus endoT CS-gene expression | `CS_genes_clustermap_CAR-T_endoT_across_CRS_stages.pdf` | Fig. 3D |
| CAR-T subcluster dynamics and CS score | `dotplot_CAR-T_subcluster_dynamics_CS_score.pdf` | Fig. S3H |
| Combined CAR-T DEG visualization | `CRS_vs_Severe_vs_Moderate_DEGs.pdf` | Fig. S3C |
| CAR-T CRS GO enrichment | `CAR-T_CRS_GO.pdf` | Fig. S3D |
| CAR-T severe-versus-moderate GO enrichment | `CAR-T_Severe_vs_Moderate_GO.pdf` | Fig. S3D |
| Before-stage CRS versus No_CRS DEG | `Before_CRS_NoCRS_DEGs.pdf` | Fig. 3E |
| CAR-T and endoT subcluster fractions | `Fra_CAR-T_vs_endoT_{group}.pdf` | Fig. S3F |
| CAR-T/endoT functional gene dotplots | `dotplot_gene_expression_CAR-T.pdf`, `dotplot_gene_expression_endoT.pdf` | Fig. S3G |
| CAR-T/endoT functional-state radial plots | `CAR-T_functional_states.pdf`, `endoT_functional_states.pdf` | Fig. 3C |
| CD4/CD8 CAR-T functional-state radial plots | `cd4_functional_states.pdf`, `cd8_functional_states.pdf` | Fig. S3E |

## Standalone CellChat scripts

| Script | Recorded output(s) | Manuscript/use mapping |
|---|---|---|
| `scripts/cellchat/analyze_cellchat_cart.R` | `CAR-T_to_monocyte_pathway_strength_by_stage_raw.csv`, `CAR-T_to_monocyte_pathway_summary_with_stage_fraction.csv`, `CAR-T_to_monocyte_pathway_fraction_barplot.pdf` | Fig. 3F |
| `scripts/cellchat/analyze_cellchat_covid19.R` | `mono_to_lymph_interaction_strength_M_vs_S.csv`, `mono_to_lymph_interaction_strength_M_vs_S.pdf`, `CellChat_Significant_LR_Interactions_Moderate_vs_Severe.pdf`, `mono_to_lymph_pathway_information_flow_M_vs_S.csv`, `rankNet_mono_to_lymph_M_vs_S.pdf` | Fig. 4F, Fig. 4G, Fig. S4E |
| `scripts/cellchat/analyze_cellchat_sle.R` | `CD16_vs_CD14_outgoing_signaling.pdf`, `monocyte_incoming_pathways.pdf`, `FigS5H_incoming_pathway_signaling_strength_source_data.csv`, `outgoing_centrality_Moderate.csv`, `outgoing_centrality_Severe.csv`, `monocyte_outgoing_pathways.pdf`, `FigS5H_outgoing_pathway_signaling_strength_source_data.csv`, `chord_diagram_incoming_monocytes_severe_SLE.pdf` | Fig. 5H, Fig. S5H, Fig. S5I |
