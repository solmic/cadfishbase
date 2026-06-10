# ── 08_spd_joined.R ───────────────────────────────────────────────────────────
# Builds joined SPD tables with selected columns and prefixes applied.
# One row per species per life stage (adult, juvenile, larva).
# Produces: three boundary joined Excel files in outputs/joined/

source(here("R", "07_spd_boundaries.R"))

message("Building SPD joined tables...")

# ── Build joined SPD table function ──────────────────────────────────────────
build_spd_table <- function(df, species_list) {
  df |>
    filter(sci_name %in% species_list) |>
    mutate(across(where(is.numeric), ~ ifelse(. == -9999, NA, .))) |>
    select(
      class, order, family, genus, sci_name, tax_level, life_stage,
      depth_min, depth_max, temp_min, temp_max, temp_mean,
      vert_habitat, vert_epipelagic, vert_mesopelagic,
      vert_bathypelagic, vert_demersal, vert_benthic,
      horz_habitat, horz_coastal, horz_continental_shelf,
      horz_continental_slope, horz_oceanic,
      diel_migrant, season_migrant, gregarious,
      body_shape, l_min_TL, l_max_TL, phys_defense, defense_spines,
      exoskeleton, transparent, col_disrupt, silver, countershade, photophore,
      TL_BH, SL_TL, eye_TL,
      trophic_level, IUCN_status,
      lipid, protein, energy, lipid_pacific, protein_pacific, energy_pacific
    ) |>
    rename(
      ID_class = class, ID_order = order, ID_family = family,
      ID_genus = genus, ID_sci_name = sci_name, ID_tax_level = tax_level,
      ID_life_stage = life_stage,
      Hab_depth_min = depth_min, Hab_depth_max = depth_max,
      Hab_temp_min = temp_min, Hab_temp_max = temp_max,
      Hab_temp_mean = temp_mean,
      HabV_primary = vert_habitat, HabV_epipelagic = vert_epipelagic,
      HabV_mesopelagic = vert_mesopelagic, HabV_bathypelagic = vert_bathypelagic,
      HabV_demersal = vert_demersal, HabV_benthic = vert_benthic,
      HabH_primary = horz_habitat, HabH_coastal = horz_coastal,
      HabH_continental_shelf = horz_continental_shelf,
      HabH_continental_slope = horz_continental_slope,
      HabH_oceanic = horz_oceanic,
      Beh_diel_migrant = diel_migrant, Beh_season_migrant = season_migrant,
      Beh_gregarious = gregarious,
      Morph_body_shape = body_shape, Morph_l_min_TL = l_min_TL,
      Morph_l_max_TL = l_max_TL, Morph_phys_defense = phys_defense,
      Morph_defense_spines = defense_spines, Morph_exoskeleton = exoskeleton,
      Morph_transparent = transparent, Morph_col_disrupt = col_disrupt,
      Morph_silver = silver, Morph_countershade = countershade,
      Morph_photophore = photophore,
      Metric_TL_BH = TL_BH, Metric_SL_TL = SL_TL, Metric_eye_TL = eye_TL,
      Pop_trophic_level = trophic_level, Pop_IUCN_status = IUCN_status,
      Nutr_lipid = lipid, Nutr_protein = protein, Nutr_energy = energy,
      Nutr_lipid_pacific = lipid_pacific, Nutr_protein_pacific = protein_pacific,
      Nutr_energy_pacific = energy_pacific
    )
}

# ── Build tables ──────────────────────────────────────────────────────────────
spd_plankton_joined <- build_spd_table(all_traits, plankton_names)
spd_forage_joined   <- build_spd_table(all_traits, forage_names)
spd_pacific_joined  <- build_spd_table(all_traits, pacific_names)

cat("Plankton:", n_distinct(spd_plankton_joined$ID_sci_name),
    "species |", nrow(spd_plankton_joined), "rows\n")
cat("Forage:  ", n_distinct(spd_forage_joined$ID_sci_name),
    "species |", nrow(spd_forage_joined), "rows\n")
cat("Pacific: ", n_distinct(spd_pacific_joined$ID_sci_name),
    "species |", nrow(spd_pacific_joined), "rows\n")

write_xlsx(as.data.frame(spd_plankton_joined),
           here("outputs", "joined", "planktonfish_spd_joined.xlsx"))
write_xlsx(as.data.frame(spd_forage_joined),
           here("outputs", "joined", "foragefish_spd_joined.xlsx"))
write_xlsx(as.data.frame(spd_pacific_joined),
           here("outputs", "joined", "pacific_foragefish_spd_joined.xlsx"))

message("SPD joined tables complete!")