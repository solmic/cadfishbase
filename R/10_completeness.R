# ── 10_completeness.R ─────────────────────────────────────────────────────────
# Calculates data completeness (% non-NA) for each trait column across
# the three boundaries for both FishBase and SPD joined tables.
# Produces: completeness_fishbase.xlsx and completeness_spd.xlsx

source(here("R", "05_fishbase_joined.R"))
source(here("R", "08_spd_joined.R"))

message("Calculating completeness...")

out_dir <- here("outputs", "reference")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ── Completeness function ─────────────────────────────────────────────────────
calc_completeness <- function(forage, plankton, pacific, label) {
  comp_forage   <- forage   |>
    summarise(across(everything(), ~ round(mean(!is.na(.)) * 100, 1))) |>
    pivot_longer(everything(), names_to = "column",
                 values_to = "pct_complete_forage")
  
  comp_plankton <- plankton |>
    summarise(across(everything(), ~ round(mean(!is.na(.)) * 100, 1))) |>
    pivot_longer(everything(), names_to = "column",
                 values_to = "pct_complete_plankton")
  
  comp_pacific  <- pacific  |>
    summarise(across(everything(), ~ round(mean(!is.na(.)) * 100, 1))) |>
    pivot_longer(everything(), names_to = "column",
                 values_to = "pct_complete_pacific")
  
  comp_forage |>
    left_join(comp_plankton, by = "column") |>
    left_join(comp_pacific,  by = "column") |>
    arrange(column)
}

# ── FishBase completeness ─────────────────────────────────────────────────────
fb_completeness <- calc_completeness(
  forage_joined, plankton_joined, pacific_joined, "FishBase"
)

write_xlsx(as.data.frame(fb_completeness),
           file.path(out_dir, "completeness_fishbase.xlsx"))
cat("FishBase completeness saved\n")

# ── SPD completeness ──────────────────────────────────────────────────────────
spd_completeness <- calc_completeness(
  spd_forage_joined, spd_plankton_joined, spd_pacific_joined, "SPD"
)

write_xlsx(as.data.frame(spd_completeness),
           file.path(out_dir, "completeness_spd.xlsx"))
cat("SPD completeness saved\n")

message("Completeness assessment complete!")