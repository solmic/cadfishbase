# ── 06_spd_extraction.R ───────────────────────────────────────────────────────
# Loads the Pelagic Species Trait Database (SPD) and filters to Canadian
# species matched against the FishBase Canadian species list.
# SPD files must be placed in: data/raw/spd/
# Download from: https://doi.org/10.5683/SP3/0YFJED
# Produces: canada_all_traits, and one Excel file per table

source(here("R", "02_canada_species.R"))

message("Loading SPD database...")

# ── SPD file paths ────────────────────────────────────────────────────────────
spd_path <- here("data", "raw", "spd")

# ── Load all SPD tables ───────────────────────────────────────────────────────
all_traits    <- read.csv(file.path(spd_path, "overview", "all_traits",
                                    "1_pelagic_species_trait_database.csv"))
habitat_beh   <- read.csv(file.path(spd_path, "trait_data", "habitat_behavioral",
                                    "3_habitat_behavior_traits.csv"))
morphological <- read.csv(file.path(spd_path, "trait_data", "morphological",
                                    "4_morphological_traits.csv"))
nutritional   <- read.csv(file.path(spd_path, "trait_data", "nutritional_quality",
                                    "6_nutritional_traits.csv"))
pop_status    <- read.csv(file.path(spd_path, "trait_data", "population_status",
                                    "8_population_status_traits.csv"))

cat("Total species in SPD:", n_distinct(all_traits$sci_name), "\n")

# ── Clean -9999 to NA (numeric columns only) ──────────────────────────────────
clean <- function(df) {
  df |> mutate(across(where(is.numeric), ~ ifelse(. == -9999, NA, .)))
}

# ── Filter to Canadian species ────────────────────────────────────────────────
canada_all_traits    <- all_traits    |> filter(sci_name %in% canada_names) |> clean()
canada_habitat_beh   <- habitat_beh   |> filter(sci_name %in% canada_names) |> clean()
canada_morphological <- morphological |> filter(sci_name %in% canada_names) |> clean()
canada_nutritional   <- nutritional   |> filter(sci_name %in% canada_names) |> clean()
canada_pop_status    <- pop_status    |> filter(sci_name %in% canada_names) |> clean()

cat("Canadian species in SPD:", n_distinct(canada_all_traits$sci_name), "\n")
cat("Rows per table:\n")
cat("  Table 1 (all traits):   ", nrow(canada_all_traits), "\n")
cat("  Table 3 (habitat/beh):  ", nrow(canada_habitat_beh), "\n")
cat("  Table 4 (morphological):", nrow(canada_morphological), "\n")
cat("  Table 6 (nutritional):  ", nrow(canada_nutritional), "\n")
cat("  Table 8 (pop status):   ", nrow(canada_pop_status), "\n")

# ── Save to outputs ───────────────────────────────────────────────────────────
out_dir <- here("outputs", "smallpelagic_canada")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

write_xlsx(as.data.frame(canada_all_traits),    file.path(out_dir, "canada_all_traits.xlsx"))
write_xlsx(as.data.frame(canada_habitat_beh),   file.path(out_dir, "canada_habitat_behavior.xlsx"))
write_xlsx(as.data.frame(canada_morphological), file.path(out_dir, "canada_morphological.xlsx"))
write_xlsx(as.data.frame(canada_nutritional),   file.path(out_dir, "canada_nutritional.xlsx"))
write_xlsx(as.data.frame(canada_pop_status),    file.path(out_dir, "canada_pop_status.xlsx"))

message("SPD extraction complete!")