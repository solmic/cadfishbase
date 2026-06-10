# ── 03_fishbase_extraction.R ──────────────────────────────────────────────────
# Extracts all 18 trait tables from FishBase for Canadian species.
# Produces: one Excel file per table saved to outputs/fishbase_canada/

source(here("R", "02_canada_species.R"))

message("Extracting FishBase tables for Canadian species...")

out_dir <- here("outputs", "fishbase_canada")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ── Safe filter function (handles Speccode vs SpecCode) ───────────────────────
safe_filter <- function(tbl_name, codes) {
  tryCatch({
    tbl <- fb_tbl(tbl_name)
    if ("SpecCode" %in% names(tbl)) {
      tbl |> filter(SpecCode %in% codes)
    } else if ("Speccode" %in% names(tbl)) {
      tbl |> filter(Speccode %in% codes)
    } else {
      message("No SpecCode column in: ", tbl_name)
      NULL
    }
  }, error = function(e) {
    message("Error in table: ", tbl_name, " - ", e$message)
    NULL
  })
}

# ── Extract all 18 tables ─────────────────────────────────────────────────────
table_list <- list(
  species       = safe_filter("species",   spec_codes),
  ecology       = safe_filter("ecology",   spec_codes),
  length_weight = safe_filter("poplw",     spec_codes),
  length_length = safe_filter("popll",     spec_codes),
  popgrowth     = safe_filter("popgrowth", spec_codes),
  fecundity     = safe_filter("fecundity", spec_codes),
  spawning      = safe_filter("spawning",  spec_codes),
  larvae        = safe_filter("larvae",    spec_codes),
  swimming      = safe_filter("swimming",  spec_codes),
  predators     = safe_filter("predats",   spec_codes),
  maturity      = safe_filter("maturity",  spec_codes),
  morphology    = safe_filter("morphdat",  spec_codes),
  oxygen        = safe_filter("oxygen",    spec_codes),
  speed         = safe_filter("speed",     spec_codes),
  brains        = safe_filter("brains",    spec_codes),
  genetics      = safe_filter("genetics",  spec_codes),
  reproduc      = safe_filter("reproduc",  spec_codes),
  fooditems     = safe_filter("fooditems", spec_codes)
)

# ── Save each table ───────────────────────────────────────────────────────────
for (name in names(table_list)) {
  if (!is.null(table_list[[name]])) {
    write_xlsx(
      as.data.frame(table_list[[name]]),
      file.path(out_dir, paste0(name, ".xlsx"))
    )
    cat("Saved:", name, "—", nrow(table_list[[name]]), "rows\n")
  }
}

message("FishBase extraction complete! Files saved to outputs/fishbase_canada/")