## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

opts <- options(keyring_warn_for_env_fallback = FALSE)

# load the library
library(ncdf4)
library(terra)
library(maps)
library(ecmwfr)

## ----eval = FALSE-------------------------------------------------------------
#  list(
#        product_type = 'reanalysis',
#        variable = 'geopotential',
#        year = '2024',
#        month = '03',
#        day = '01',
#        time = '13:00',
#        pressure_level = '1000',
#        data_format = 'grib',
#        dataset_short_name = 'reanalysis-era5-pressure-levels',
#        target = 'test.grib'
#  ) |>
#    wf_request(path = "~")

## ----eval = FALSE-------------------------------------------------------------
#  # this is an example of a request
#  dynamic_request <- wf_archetype(
#    request = list(
#        product_type = 'reanalysis',
#        variable = 'geopotential',
#        year = '2024',
#        month = '03',
#        day = '01',
#        time = '13:00',
#        pressure_level = '1000',
#        data_format = 'grib',
#        dataset_short_name = 'reanalysis-era5-pressure-levels',
#        target = 'test.grib'
#    ),
#    dynamic_fields = c("day", "target"))
#  
#  # change the day of the month
#  dynamic_request(day = "01", target = "new.grib") |>
#    wf_request()

## ----eval = FALSE-------------------------------------------------------------
#  # creating a list of requests using wf_archetype()
#  # setting the day value
#  batch_request <- list(
#    dynamic_request(day = "01"),
#    dynamic_request(day = "02")
#  )
#  
#  # submit a batch job using 2 workers
#  # one for each in the list (the number of workers
#  # can't exceed 20)
#  wf_request_batch(
#    batch_request,
#    workers = 2
#    )

## ----eval=FALSE---------------------------------------------------------------
#  # CDS
#  cds_request <-
#    list(
#        product_type = 'reanalysis',
#        variable = 'geopotential',
#        year = '2024',
#        month = '03',
#        day = '01',
#        time = '13:00',
#        pressure_level = '1000',
#        data_format = 'grib',
#        dataset_short_name = 'reanalysis-era5-pressure-levels',
#        target = 'test.grib'
#  )
#  
#  # ADS
#  ads_request <- list(
#    dataset_short_name = "cams-global-radiative-forcings",
#    variable = "radiative_forcing_of_carbon_dioxide",
#    forcing_type = "instantaneous",
#    band = "long_wave",
#    sky_type = "all_sky",
#    level = "surface",
#    version = "2",
#    year = "2018",
#    month = "06",
#    target = "download.grib"
#  )
#  
#  
#  combined_request <- list(
#    cds_request,
#    ads_request
#  )
#  
#  
#  files <- wf_request_batch(
#    combined_request
#    )

## ----eval=FALSE---------------------------------------------------------------
#   Sys.setenv(ecmwfr_PAT="abcd1234-foo-bar-98765431-XXXXXXXXXX")

