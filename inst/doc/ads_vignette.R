## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

# load the library
library(ncdf4)
library(raster)
library(terra)
library(maps)

## ----demo request, echo = TRUE------------------------------------------------
# Specify the data set
request <- list(
  date = "2003-01-01/2003-01-01",
  format = "netcdf",
  variable = "particulate_matter_2.5um",
  time = "00:00",
  dataset_short_name = "cams-global-reanalysis-eac4",
  target = "particulate_matter.nc"
)

## ----spatial-request, echo = TRUE, eval = FALSE-------------------------------
#  # Start downloading the data, the path of the file
#  # will be returned as a variable (ncfile)
#  file <- wf_request(
#    user     = "2345",   # user ID (for authentification)
#    request  = request,  # the request
#    transfer = TRUE,     # download the file
#    path     = "."       # store data in current working directory
#    )

## ----echo = FALSE-------------------------------------------------------------
ncfile <- system.file(package = "ecmwfr","extdata/ads.nc")

## ----spatial-plot, echo = TRUE, figure = TRUE, fig.width = 8, fig.height = 6----
# Open NetCDF file and plot
# the log transformed data
r <- raster::raster(ncfile)
raster::plot(log(rotate(r)),
             main = "CAMS reanalysis data (particulate matter 2.5u)",
             col = rev(heat.colors(100)))
maps::map("world", add = TRUE)

