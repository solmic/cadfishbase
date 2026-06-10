# ── 01_load_packages.R ────────────────────────────────────────────────────────
# Installs and loads all packages required for the forage fish vulnerability
# assessment pipeline. Run this script first before any other.

packages <- c(
  "rfishbase",  # FishBase data extraction
  "dplyr",      # data manipulation
  "tidyr",      # data reshaping
  "readr",      # reading CSV files
  "writexl",    # writing Excel files
  "stringr",    # string manipulation
  "here"        # reproducible file paths
)

# Install any missing packages
installed <- rownames(installed.packages())
to_install <- packages[!packages %in% installed]
if (length(to_install) > 0) {
  message("Installing missing packages: ", paste(to_install, collapse = ", "))
  install.packages(to_install)
}

# Load all packages
lapply(packages, library, character.only = TRUE)

message("All packages loaded successfully!")