# Forage Fish Vulnerability Assessment

## Overview
This project builds a comprehensive trait database for forage fish species 
found in Canada to assess vulnerability across life stages. 

Trait data are drawn from two sources:
- **FishBase** — accessed via the `rfishbase` R package
- **Pelagic Species Trait Database (SPD)** — Gleiber et al. 
  https://doi.org/10.5683/SP3/0YFJED

## Species Boundaries
Three sequential filters are applied:
1. **Plankton feeders** — FeedingType: selective plankton feeding or filtering plankton
2. **Forage fish** — Maximum body length ≤ 50 cm
3. **Pacific forage fish** — Occurrence in FAO areas 61 and 67

## Project Structure
- `R/` — all scripts numbered in order of execution
- `data/raw/` — raw input data (SPD files)
- `data/processed/` — extracted and filtered tables
- `outputs/joined/` — final joined trait tables per boundary
- `outputs/reference/` — trait reference and completeness tables
- `docs/` — data selection rationale and methods documentation

## How to Run
1. Download SPD database from https://doi.org/10.5683/SP3/0YFJED
2. Place files in `data/raw/spd/`
3. Run scripts in order: 01 → 02 → 03 etc.

## Dependencies
See `R/01_load_packages.R`

## Citation
If using this database please cite:
- Froese, R. and D. Pauly (Editors). FishBase. www.fishbase.org
- Gleiber et al. Pelagic Species Trait Database. https://doi.org/10.5683/SP3/0YFJED