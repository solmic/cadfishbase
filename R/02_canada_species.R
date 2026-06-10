# ── 02_canada_species.R ───────────────────────────────────────────────────────
# Gets all fish species recorded in Canada from FishBase and builds the
# species name list used throughout the pipeline.
# Produces: spec_codes, canada_names, plankton_codes, forage_codes,
#           pacific_forage_codes, plankton_names, forage_names, pacific_names

source(here("R", "01_load_packages.R"))

message("Getting Canadian species from FishBase...")

# ── Step 1: Canadian species codes ───────────────────────────────────────────
canada_spp <- fb_tbl("country") |>
  filter(C_Code == "124")

spec_codes <- unique(canada_spp$SpecCode)
cat("Total Canadian species in FishBase:", length(spec_codes), "\n")

# ── Step 2: Full species names ────────────────────────────────────────────────
canada_names <- fb_tbl("species") |>
  filter(SpecCode %in% spec_codes) |>
  mutate(Full_Name = paste(Genus, Species)) |>
  pull(Full_Name) |>
  unique()

cat("Canadian species with full names:", length(canada_names), "\n")

# ── Step 3: Filter table for boundary application ─────────────────────────────
filter_table <- fb_tbl("species") |>
  filter(SpecCode %in% spec_codes) |>
  select(SpecCode, Length) |>
  left_join(
    fb_tbl("ecology") |>
      filter(SpecCode %in% spec_codes) |>
      select(SpecCode, FeedingType),
    by = "SpecCode"
  )

# ── Boundary 1: Plankton feeders ──────────────────────────────────────────────
plankton_codes <- filter_table |>
  filter(FeedingType %in% c("selective plankton feeding",
                            "filtering plankton")) |>
  pull(SpecCode) |>
  unique()

cat("Boundary 1 - Plankton feeders:", length(plankton_codes), "species\n")

# ── Boundary 2: Size <= 50cm ──────────────────────────────────────────────────
forage_codes <- filter_table |>
  filter(FeedingType %in% c("selective plankton feeding",
                            "filtering plankton"),
         Length <= 50) |>
  pull(SpecCode) |>
  unique()

cat("Boundary 2 - Forage fish:", length(forage_codes), "species\n")

# ── Boundary 3: Pacific only (FAO areas 61 and 67) ───────────────────────────
pacific_codes <- fb_tbl("countfao") |>
  filter(C_Code == "124", AreaCode %in% c(61, 67)) |>
  pull(SpecCode) |>
  unique()

pacific_forage_codes <- intersect(forage_codes, pacific_codes)

cat("Boundary 3 - Pacific forage fish:", length(pacific_forage_codes), "species\n")

# ── Step 4: Build full name vectors for each boundary ─────────────────────────
get_names <- function(codes) {
  fb_tbl("species") |>
    filter(SpecCode %in% codes) |>
    mutate(Full_Name = paste(Genus, Species)) |>
    pull(Full_Name)
}

plankton_names        <- get_names(plankton_codes)
forage_names          <- get_names(forage_codes)
pacific_names         <- get_names(pacific_forage_codes)

message("Species codes and names ready!")