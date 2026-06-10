# ── 04_fishbase_boundaries.R ──────────────────────────────────────────────────
# Applies the three forage fish boundaries to FishBase data and exports
# separate table sets per boundary.
# Produces: three subfolders in outputs/fishbase_canada/ with 18 tables each

source(here("R", "02_canada_species.R"))

message("Applying boundaries to FishBase tables...")

base_dir <- here("outputs", "fishbase_canada")

# ── Safe filter function ──────────────────────────────────────────────────────
safe_filter <- function(tbl_name, codes) {
  tryCatch({
    tbl <- fb_tbl(tbl_name)
    if ("SpecCode" %in% names(tbl)) {
      tbl |> filter(SpecCode %in% codes)
    } else if ("Speccode" %in% names(tbl)) {
      tbl |> filter(Speccode %in% codes)
    } else {
      NULL
    }
  }, error = function(e) NULL)
}

# ── Function to pull all 18 tables for a set of codes ────────────────────────
pull_all_tables <- function(codes) {
  list(
    species       = safe_filter("species",   codes),
    ecology       = safe_filter("ecology",   codes),
    length_weight = safe_filter("poplw",     codes),
    length_length = safe_filter("popll",     codes),
    popgrowth     = safe_filter("popgrowth", codes),
    fecundity     = safe_filter("fecundity", codes),
    spawning      = safe_filter("spawning",  codes),
    larvae        = safe_filter("larvae",    codes),
    swimming      = safe_filter("swimming",  codes),
    predators     = safe_filter("predats",   codes),
    maturity      = safe_filter("maturity",  codes),
    morphology    = safe_filter("morphdat",  codes),
    oxygen        = safe_filter("oxygen",    codes),
    speed         = safe_filter("speed",     codes),
    brains        = safe_filter("brains",    codes),
    genetics      = safe_filter("genetics",  codes),
    reproduc      = safe_filter("reproduc",  codes),
    fooditems     = safe_filter("fooditems", codes)
  )
}

# ── Function to save tables to a subfolder ────────────────────────────────────
save_tables <- function(table_list, subfolder) {
  out_dir <- file.path(base_dir, subfolder)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  for (name in names(table_list)) {
    if (!is.null(table_list[[name]])) {
      write_xlsx(
        as.data.frame(table_list[[name]]),
        file.path(out_dir, paste0(name, ".xlsx"))
      )
      cat("Saved:", subfolder, "/", name, "\n")
    }
  }
}

# ── Pull and save for each boundary ──────────────────────────────────────────
message("Pulling plankton feeder tables...")
plankton_tables <- pull_all_tables(plankton_codes)
save_tables(plankton_tables, "planktonfish_tables")

message("Pulling forage fish tables...")
forage_tables <- pull_all_tables(forage_codes)
save_tables(forage_tables, "foragefish_tables")

message("Pulling pacific forage fish tables...")
pacific_tables <- pull_all_tables(pacific_forage_codes)
save_tables(pacific_tables, "pacific_foragefish_tables")

message("FishBase boundary tables complete!")