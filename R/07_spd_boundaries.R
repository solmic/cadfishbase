# ── 07_spd_boundaries.R ───────────────────────────────────────────────────────
# Applies the three forage fish boundaries to SPD data using species name
# matching against FishBase boundary species lists.
# Produces: three boundary Excel files in outputs/smallpelagic_canada/

source(here("R", "06_spd_extraction.R"))

message("Applying boundaries to SPD data...")

# ── Clean function ────────────────────────────────────────────────────────────
clean <- function(df) {
  df |> mutate(across(where(is.numeric), ~ ifelse(. == -9999, NA, .)))
}

# ── Filter to each boundary ───────────────────────────────────────────────────
spd_plankton <- all_traits |> filter(sci_name %in% plankton_names) |> clean()
spd_forage   <- all_traits |> filter(sci_name %in% forage_names)   |> clean()
spd_pacific  <- all_traits |> filter(sci_name %in% pacific_names)  |> clean()

cat("Plankton:", n_distinct(spd_plankton$sci_name), "species |",
    nrow(spd_plankton), "rows\n")
cat("Forage:  ", n_distinct(spd_forage$sci_name),   "species |",
    nrow(spd_forage),   "rows\n")
cat("Pacific: ", n_distinct(spd_pacific$sci_name),  "species |",
    nrow(spd_pacific),  "rows\n")

out_dir <- here("outputs", "smallpelagic_canada")

write_xlsx(as.data.frame(spd_plankton),
           file.path(out_dir, "planktonfish_spd.xlsx"))
write_xlsx(as.data.frame(spd_forage),
           file.path(out_dir, "foragefish_spd.xlsx"))
write_xlsx(as.data.frame(spd_pacific),
           file.path(out_dir, "pacific_foragefish_spd.xlsx"))

message("SPD boundary tables complete!")