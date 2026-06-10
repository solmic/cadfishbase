# ── 09_overlap_comparison.R ───────────────────────────────────────────────────
# Builds a side-by-side comparison table of overlapping traits between
# FishBase and SPD for manual review and conflict resolution.
# Produces: overlap_comparison.xlsx in outputs/

source(here("R", "05_fishbase_joined.R"))
source(here("R", "08_spd_joined.R"))

message("Building overlap comparison table...")

# ── FishBase overlapping columns ──────────────────────────────────────────────
fb_overlap <- forage_joined |>
  select(
    Full_Name,
    Spp_Genus,
    Spp_BodyShapeI,
    Spp_DepthRangeShallow,
    Spp_DepthRangeDeep,
    Eco_FeedingType,
    Eco_DietTroph,
    Eco_FoodTroph,
    Eco_Epipelagic,
    Eco_Mesopelagic,
    Eco_Schooling,
    Eco_Shoaling,
    Eco_Circadian1
  ) |>
  rename(
    sci_name          = Full_Name,
    FB_Genus          = Spp_Genus,
    FB_BodyShape      = Spp_BodyShapeI,
    FB_DepthMin       = Spp_DepthRangeShallow,
    FB_DepthMax       = Spp_DepthRangeDeep,
    FB_FeedingType    = Eco_FeedingType,
    FB_DietTroph      = Eco_DietTroph,
    FB_FoodTroph      = Eco_FoodTroph,
    FB_Epipelagic     = Eco_Epipelagic,
    FB_Mesopelagic    = Eco_Mesopelagic,
    FB_Schooling      = Eco_Schooling,
    FB_Shoaling       = Eco_Shoaling,
    FB_DielActivity   = Eco_Circadian1
  )

# ── SPD overlapping columns (adult only for comparison) ───────────────────────
spd_overlap <- spd_forage_joined |>
  filter(ID_life_stage == "adult") |>
  select(
    ID_sci_name,
    ID_genus,
    Morph_body_shape,
    Hab_depth_min,
    Hab_depth_max,
    Pop_trophic_level,
    HabV_epipelagic,
    HabV_mesopelagic,
    Beh_gregarious,
    Beh_diel_migrant,
    Beh_season_migrant
  ) |>
  rename(
    sci_name          = ID_sci_name,
    SPD_Genus         = ID_genus,
    SPD_BodyShape     = Morph_body_shape,
    SPD_DepthMin      = Hab_depth_min,
    SPD_DepthMax      = Hab_depth_max,
    SPD_TrophicLevel  = Pop_trophic_level,
    SPD_Epipelagic    = HabV_epipelagic,
    SPD_Mesopelagic   = HabV_mesopelagic,
    SPD_Gregarious    = Beh_gregarious,
    SPD_DielMigrant   = Beh_diel_migrant,
    SPD_SeasonMigrant = Beh_season_migrant
  )

# ── Join side by side ─────────────────────────────────────────────────────────
overlap_comparison <- fb_overlap |>
  full_join(spd_overlap, by = "sci_name") |>
  arrange(sci_name) |>
  select(
    sci_name,
    FB_Genus, SPD_Genus,
    FB_BodyShape, SPD_BodyShape,
    FB_DepthMin, SPD_DepthMin,
    FB_DepthMax, SPD_DepthMax,
    FB_DietTroph, FB_FoodTroph, SPD_TrophicLevel,
    FB_Epipelagic, SPD_Epipelagic,
    FB_Mesopelagic, SPD_Mesopelagic,
    FB_Schooling, FB_Shoaling, SPD_Gregarious,
    FB_DielActivity, SPD_DielMigrant,
    SPD_SeasonMigrant,
    FB_FeedingType
  )

cat("Species in comparison table:", nrow(overlap_comparison), "\n")
cat("In FishBase only:", sum(is.na(overlap_comparison$SPD_BodyShape)), "\n")
cat("In SPD only:", sum(is.na(overlap_comparison$FB_BodyShape)), "\n")
cat("In both:", sum(!is.na(overlap_comparison$FB_BodyShape) &
                      !is.na(overlap_comparison$SPD_BodyShape)), "\n")

write_xlsx(
  as.data.frame(overlap_comparison),
  here("outputs", "overlap_comparison.xlsx")
)

message("Overlap comparison table complete!")
message("Review outputs/overlap_comparison.xlsx and resolve conflicts manually.")
message("Then run 10_master_joined.R to build the final master table.")