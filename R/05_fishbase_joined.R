# ── 05_fishbase_joined.R ──────────────────────────────────────────────────────
# Builds one joined table per boundary from FishBase data.
# Selected columns only, prefixed by table name, one row per species.
# Produces: foragefish_joined.xlsx, planktonfish_joined.xlsx,
#           pacific_foragefish_joined.xlsx in outputs/joined/

source(here("R", "02_canada_species.R"))

message("Building FishBase joined tables...")

out_dir <- here("outputs", "joined")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ── Master join function ──────────────────────────────────────────────────────
build_joined_table <- function(codes) {
  
  spp <- fb_tbl("species") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, Genus, Species, FBname, BodyShapeI, Length,
           LTypeMaxM, CommonLength, Fresh, Brack, Saltwater,
           DemersPelag, AnaCat, DepthRangeShallow, DepthRangeDeep,
           LongevityWild, Vulnerability, VulnerabilityClimate, Importance) |>
    mutate(Full_Name = paste(Genus, Species)) |>
    rename(Spp_Genus = Genus, Spp_Species = Species, Spp_FBname = FBname,
           Spp_BodyShapeI = BodyShapeI, Spp_Length = Length,
           Spp_LTypeMaxM = LTypeMaxM, Spp_CommonLength = CommonLength,
           Spp_Fresh = Fresh, Spp_Brack = Brack, Spp_Saltwater = Saltwater,
           Spp_DemersPelag = DemersPelag, Spp_AnaCat = AnaCat,
           Spp_DepthRangeShallow = DepthRangeShallow,
           Spp_DepthRangeDeep = DepthRangeDeep,
           Spp_LongevityWild = LongevityWild,
           Spp_Vulnerability = Vulnerability,
           Spp_VulnerabilityClimate = VulnerabilityClimate,
           Spp_Importance = Importance) |>
    select(SpecCode, Full_Name, everything())
  
  eco <- fb_tbl("ecology") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, FeedingType, DietTroph, FoodTroph, Herbivory2,
           Neritic, Oceanic, Epipelagic, Mesopelagic, Pelagic, Estuaries,
           Schooling, SchoolingFrequency, Shoaling, ShoalingFrequency,
           Circadian1, Circadian2, Circadian3,
           BioAspect1, BioAspect2, BioAspect3) |>
    rename(Eco_FeedingType = FeedingType, Eco_DietTroph = DietTroph,
           Eco_FoodTroph = FoodTroph, Eco_Herbivory2 = Herbivory2,
           Eco_Neritic = Neritic, Eco_Oceanic = Oceanic,
           Eco_Epipelagic = Epipelagic, Eco_Mesopelagic = Mesopelagic,
           Eco_Pelagic = Pelagic, Eco_Estuaries = Estuaries,
           Eco_Schooling = Schooling,
           Eco_SchoolingFrequency = SchoolingFrequency,
           Eco_Shoaling = Shoaling,
           Eco_ShoalingFrequency = ShoalingFrequency,
           Eco_Circadian1 = Circadian1, Eco_Circadian2 = Circadian2,
           Eco_Circadian3 = Circadian3,
           Eco_BioAspect1 = BioAspect1, Eco_BioAspect2 = BioAspect2,
           Eco_BioAspect3 = BioAspect3) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  lw <- fb_tbl("poplw") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, Sex, a, aTL, b, Type, LengthMin, LengthMax) |>
    rename(LW_Sex = Sex, LW_a = a, LW_aTL = aTL, LW_b = b,
           LW_Type = Type, LW_LengthMin = LengthMin,
           LW_LengthMax = LengthMax) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  ll <- fb_tbl("popll") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, Length1, Length2, a, b, LengthMin, LengthMax) |>
    rename(LL_Length1 = Length1, LL_Length2 = Length2,
           LL_a = a, LL_b = b,
           LL_LengthMin = LengthMin, LL_LengthMax = LengthMax) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  growth <- fb_tbl("popgrowth") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, Sex, Loo, K, to, tmax, M, Lm, Temperature) |>
    rename(Growth_Sex = Sex, Growth_Loo = Loo, Growth_K = K,
           Growth_to = to, Growth_tmax = tmax, Growth_M = M,
           Growth_Lm = Lm, Growth_Temperature = Temperature) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  fec <- fb_tbl("fecundity") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, FecundityMin, FecundityMax, FecundityMean,
           RelFecundityMin, RelFecundityMax, RelFecundityMean,
           SpawningCycles) |>
    rename(Fec_FecundityMin = FecundityMin, Fec_FecundityMax = FecundityMax,
           Fec_FecundityMean = FecundityMean,
           Fec_RelFecundityMin = RelFecundityMin,
           Fec_RelFecundityMax = RelFecundityMax,
           Fec_RelFecundityMean = RelFecundityMean,
           Fec_SpawningCycles = SpawningCycles) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  spawn <- fb_tbl("spawning") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, SpawningGround, Spawningarea,
           Jan, Feb, Mar, Apr, May, Jun,
           Jul, Aug, Sep, Oct, Nov, Dec,
           TempLow, TempHigh, SpawningCycles) |>
    rename(Spawn_SpawningGround = SpawningGround,
           Spawn_Spawningarea = Spawningarea,
           Spawn_Jan = Jan, Spawn_Feb = Feb, Spawn_Mar = Mar,
           Spawn_Apr = Apr, Spawn_May = May, Spawn_Jun = Jun,
           Spawn_Jul = Jul, Spawn_Aug = Aug, Spawn_Sep = Sep,
           Spawn_Oct = Oct, Spawn_Nov = Nov, Spawn_Dec = Dec,
           Spawn_TempLow = TempLow, Spawn_TempHigh = TempHigh,
           Spawn_SpawningCycles = SpawningCycles) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  larv <- fb_tbl("larvae") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, LarvalArea, PlaceofDevelopment,
           LhMax, LhMin, LhMid,
           LarvalDurationMin, LarvalDurationMax, LarvalDurationMod,
           JanLarv, FebLarv, MarLarv, AprLarv, MayLarv, JunLarv,
           JulLarv, AugLarv, SepLarv, OctLarv, NovLarv, DecLarv,
           WaterTempMin, WaterTempMax, WaterTempMod,
           SalinityMin, SalinityMax, SalinityMod,
           OxygenMin, OxygenMax, OxygenMod,
           WaterDepthMin, WaterDepthMax, WaterDepthMod) |>
    rename(Larv_LarvalArea = LarvalArea,
           Larv_PlaceofDevelopment = PlaceofDevelopment,
           Larv_LhMax = LhMax, Larv_LhMin = LhMin, Larv_LhMid = LhMid,
           Larv_DurationMin = LarvalDurationMin,
           Larv_DurationMax = LarvalDurationMax,
           Larv_DurationMod = LarvalDurationMod,
           Larv_Jan = JanLarv, Larv_Feb = FebLarv, Larv_Mar = MarLarv,
           Larv_Apr = AprLarv, Larv_May = MayLarv, Larv_Jun = JunLarv,
           Larv_Jul = JulLarv, Larv_Aug = AugLarv, Larv_Sep = SepLarv,
           Larv_Oct = OctLarv, Larv_Nov = NovLarv, Larv_Dec = DecLarv,
           Larv_WaterTempMin = WaterTempMin, Larv_WaterTempMax = WaterTempMax,
           Larv_WaterTempMod = WaterTempMod,
           Larv_SalinityMin = SalinityMin, Larv_SalinityMax = SalinityMax,
           Larv_SalinityMod = SalinityMod,
           Larv_OxygenMin = OxygenMin, Larv_OxygenMax = OxygenMax,
           Larv_OxygenMod = OxygenMod,
           Larv_DepthMin = WaterDepthMin, Larv_DepthMax = WaterDepthMax,
           Larv_DepthMod = WaterDepthMod) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  swim <- fb_tbl("swimming") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, AdultType, AdultMode, AspectRatio) |>
    rename(Swim_AdultType = AdultType, Swim_AdultMode = AdultMode,
           Swim_AspectRatio = AspectRatio) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  pred <- fb_tbl("predats") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, Predatstage, PredatorI, PredatorII,
           PredatorGroup, PredatorName, PredatTroph, PreyStage) |>
    rename(Pred_Predatstage = Predatstage, Pred_PredatorI = PredatorI,
           Pred_PredatorII = PredatorII, Pred_PredatorGroup = PredatorGroup,
           Pred_PredatorName = PredatorName, Pred_PredatTroph = PredatTroph,
           Pred_PreyStage = PreyStage) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  mat <- fb_tbl("maturity") |>
    filter(Speccode %in% codes) |>
    select(Speccode, Sex, AgeMatMin, AgeMatMin2, tm, LengthMatMin, Lm) |>
    rename(SpecCode = Speccode, Mat_Sex = Sex,
           Mat_AgeMatMin = AgeMatMin, Mat_AgeMatMin2 = AgeMatMin2,
           Mat_tm = tm, Mat_LengthMatMin = LengthMatMin, Mat_Lm = Lm) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  morph <- fb_tbl("morphdat") |>
    filter(Speccode %in% codes) |>
    select(Speccode, BodyShapeII, TypeofMouth, PosofMouth,
           GillRakersLowMin, GillRakersLowMax,
           GillRakersTotalMin, GillRakersTotalMax,
           VertebraeTotalMin, VertebraeTotalMax,
           StandardLengthCm, Totallength) |>
    rename(SpecCode = Speccode,
           Morph_BodyShapeII = BodyShapeII,
           Morph_TypeofMouth = TypeofMouth, Morph_PosofMouth = PosofMouth,
           Morph_GillRakersLowMin = GillRakersLowMin,
           Morph_GillRakersLowMax = GillRakersLowMax,
           Morph_GillRakersTotalMin = GillRakersTotalMin,
           Morph_GillRakersTotalMax = GillRakersTotalMax,
           Morph_VertebraeTotalMin = VertebraeTotalMin,
           Morph_VertebraeTotalMax = VertebraeTotalMax,
           Morph_StandardLengthCm = StandardLengthCm,
           Morph_Totallength = Totallength) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  oxy <- fb_tbl("oxygen") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, Weight, Temp, Salinity,
           OxygenCons, MetabolicLevel, AppliedStress) |>
    rename(Oxy_Weight = Weight, Oxy_Temp = Temp, Oxy_Salinity = Salinity,
           Oxy_OxygenCons = OxygenCons, Oxy_MetabolicLevel = MetabolicLevel,
           Oxy_AppliedStress = AppliedStress) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  spd <- fb_tbl("speed") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, Length, LengthType, SpeedLS, Speedms, Mode) |>
    rename(Speed_Length = Length, Speed_LengthType = LengthType,
           Speed_SpeedLS = SpeedLS, Speed_Speedms = Speedms,
           Speed_Mode = Mode) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  br <- fb_tbl("brains") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, BodyWeight, BrainWeight, EncCoeff, SL, TL) |>
    rename(Brain_BodyWeight = BodyWeight, Brain_BrainWeight = BrainWeight,
           Brain_EncCoeff = EncCoeff, Brain_SL = SL, Brain_TL = TL) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  gen <- fb_tbl("genetics") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, ChromosomeDip, ChromosomeArm, DNA) |>
    rename(Gen_ChromosomeDip = ChromosomeDip,
           Gen_ChromosomeArm = ChromosomeArm, Gen_DNA = DNA) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  repro <- fb_tbl("reproduc") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, ReproMode, Fertilization, MatingSystem,
           SpawnAgg, Spawning, BatchSpawner,
           RepGuild1, RepGuild2, ParentalCare) |>
    rename(Repro_ReproMode = ReproMode, Repro_Fertilization = Fertilization,
           Repro_MatingSystem = MatingSystem, Repro_SpawnAgg = SpawnAgg,
           Repro_Spawning = Spawning, Repro_BatchSpawner = BatchSpawner,
           Repro_RepGuild1 = RepGuild1, Repro_RepGuild2 = RepGuild2,
           Repro_ParentalCare = ParentalCare) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  food <- fb_tbl("fooditems") |>
    filter(SpecCode %in% codes) |>
    select(SpecCode, FoodI, FoodII, FoodIII, Foodgroup, Foodname,
           PreyStage, Commoness, PreyTroph, PredatorStage) |>
    rename(Food_FoodI = FoodI, Food_FoodII = FoodII, Food_FoodIII = FoodIII,
           Food_Foodgroup = Foodgroup, Food_Foodname = Foodname,
           Food_PreyStage = PreyStage, Food_Commoness = Commoness,
           Food_PreyTroph = PreyTroph, Food_PredatorStage = PredatorStage) |>
    group_by(SpecCode) |> slice(1) |> ungroup()
  
  # ── Join all tables ─────────────────────────────────────────────────────────
  spp |>
    left_join(eco,    by = "SpecCode") |>
    left_join(lw,     by = "SpecCode") |>
    left_join(ll,     by = "SpecCode") |>
    left_join(growth, by = "SpecCode") |>
    left_join(fec,    by = "SpecCode") |>
    left_join(spawn,  by = "SpecCode") |>
    left_join(larv,   by = "SpecCode") |>
    left_join(swim,   by = "SpecCode") |>
    left_join(pred,   by = "SpecCode") |>
    left_join(mat,    by = "SpecCode") |>
    left_join(morph,  by = "SpecCode") |>
    left_join(oxy,    by = "SpecCode") |>
    left_join(spd,    by = "SpecCode") |>
    left_join(br,     by = "SpecCode") |>
    left_join(gen,    by = "SpecCode") |>
    left_join(repro,  by = "SpecCode") |>
    left_join(food,   by = "SpecCode")
}

# ── Build and export ──────────────────────────────────────────────────────────
message("Building plankton feeder joined table...")
plankton_joined <- build_joined_table(plankton_codes)
cat("Rows:", nrow(plankton_joined), "| Cols:", ncol(plankton_joined), "\n")

message("Building forage fish joined table...")
forage_joined <- build_joined_table(forage_codes)
cat("Rows:", nrow(forage_joined), "| Cols:", ncol(forage_joined), "\n")

message("Building pacific forage fish joined table...")
pacific_joined <- build_joined_table(pacific_forage_codes)
cat("Rows:", nrow(pacific_joined), "| Cols:", ncol(pacific_joined), "\n")

write_xlsx(as.data.frame(plankton_joined),
           here("outputs", "joined", "planktonfish_joined.xlsx"))
write_xlsx(as.data.frame(forage_joined),
           here("outputs", "joined", "foragefish_joined.xlsx"))
write_xlsx(as.data.frame(pacific_joined),
           here("outputs", "joined", "pacific_foragefish_joined.xlsx"))

message("FishBase joined tables complete!")