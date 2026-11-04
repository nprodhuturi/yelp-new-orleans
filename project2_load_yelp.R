# =============================================================
# Project 2 — Steps 1 & 2
# Load the Yelp Open Dataset, keep only New Orleans, save as RDS
# =============================================================
# Before running:
#   1. Download "Download JSON" (Yelp-JSON.zip, ~4.35 GB) from
#      https://business.yelp.com/data/resources/open-dataset/
#      (you do NOT need the photos download)
#   2. Put Yelp-JSON.zip in data/raw/ inside your project folder
#   3. Open this project in RStudio (so the working directory is
#      the project root) and run this script top to bottom
#
# Heads-up: unzipped, the data is ~8.65 GB, so you need roughly
# 13+ GB free disk space while this runs. The review file is
# read in chunks, so it won't blow up your RAM.
# =============================================================

# install.packages(c("jsonlite", "dplyr"))  # run once if needed
library(jsonlite)
library(dplyr)

raw_dir <- "data/raw"
out_dir <- "data"
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Unzip --------------------------------------------------
# The zip contains a .tar, which contains the JSON files
zip_file <- file.path(raw_dir, "Yelp-JSON.zip")
stopifnot(file.exists(zip_file))
unzip(zip_file, exdir = raw_dir)

tar_file <- list.files(raw_dir, pattern = "\\.tar$",
                       recursive = TRUE, full.names = TRUE)[1]
if (!is.na(tar_file)) untar(tar_file, exdir = raw_dir)

# Find each JSON file wherever it landed
find_json <- function(name) {
  f <- list.files(raw_dir, pattern = paste0(name, "\\.json$"),
                  recursive = TRUE, full.names = TRUE)
  if (length(f) == 0) stop("Couldn't find the ", name, " JSON file")
  f[1]
}
business_file <- find_json("business")
review_file   <- find_json("review")
tip_file      <- find_json("tip")
checkin_file  <- find_json("checkin")
user_file     <- find_json("user")

# Helper: read a big newline-delimited JSON file in chunks,
# keeping only the rows we want from each chunk
stream_filter <- function(path, keep, pagesize = 100000) {
  chunks <- list()
  stream_in(file(path), pagesize = pagesize, handler = function(df) {
    df <- keep(df)
    if (nrow(df) > 0) chunks[[length(chunks) + 1]] <<- df
  })
  bind_rows(chunks)
}

# ---- Businesses: filter for New Orleans ---------------------
# Small enough (~150k rows) to load whole. flatten = TRUE turns
# nested attributes/hours into regular columns.
business <- stream_in(file(business_file), flatten = TRUE)

# trimws/tolower catch variants like "new orleans" or "New Orleans "
nola_business <- business %>%
  filter(tolower(trimws(city)) == "new orleans", state == "LA")

nola_ids <- nola_business$business_id
cat("New Orleans businesses:", length(nola_ids), "\n")
rm(business); gc()

# ---- Reviews, tips, check-ins for those businesses ----------
nola_reviews  <- stream_filter(review_file,  function(df) filter(df, business_id %in% nola_ids))
nola_tips     <- stream_filter(tip_file,     function(df) filter(df, business_id %in% nola_ids))
nola_checkins <- stream_filter(checkin_file, function(df) filter(df, business_id %in% nola_ids))

# ---- Users who reviewed a New Orleans business --------------
nola_user_ids <- unique(nola_reviews$user_id)
nola_users    <- stream_filter(user_file, function(df) filter(df, user_id %in% nola_user_ids))

cat("Reviews:",   nrow(nola_reviews),  "\n",
    "Tips:",      nrow(nola_tips),     "\n",
    "Check-ins:", nrow(nola_checkins), "\n",
    "Users:",     nrow(nola_users),    "\n")

# ---- Save as RDS --------------------------------------------
saveRDS(nola_business, file.path(out_dir, "nola_business.rds"))
saveRDS(nola_reviews,  file.path(out_dir, "nola_reviews.rds"))
saveRDS(nola_tips,     file.path(out_dir, "nola_tips.rds"))
saveRDS(nola_checkins, file.path(out_dir, "nola_checkins.rds"))
saveRDS(nola_users,    file.path(out_dir, "nola_users.rds"))

# Later, load with e.g.:  nola_reviews <- readRDS("data/nola_reviews.rds")

# ---- Optional: delete the raw files to free ~13 GB ----------
# Only run this AFTER checking the .rds files saved correctly!
# unlink(raw_dir, recursive = TRUE)

