## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

opts <- options(keyring_warn_for_env_fallback = FALSE)

# load the library
library(ncdf4)
library(raster)
library(maps)
library(ecmwfr)

## ----eval = FALSE--------------------------------------------------------
#  # set a key to the keychain interactively
#  user <- wf_set_key(service = "webapi")

## ----eval = FALSE--------------------------------------------------------
#  list(stream  = "oper",
#       levtype = "sfc",
#       param   = "167.128",
#       dataset = "interim",
#       step    = "0",
#       grid    = "0.75/0.75",
#       time    = "00",
#       date    = "2014-07-01/to/2014-07-02",
#       type    = "an",
#       class   = "ei",
#       area    = "73.5/-27/33/45",
#       format  = "netcdf",
#       target  = "tmp.nc") %>%
#    wf_request(user = user, path = "~")

## ----eval = FALSE--------------------------------------------------------
#  # this is an example of a request
#  dynamic_request <- wf_archetype(request = list(
#    stream  = "oper",
#    levtype = "sfc",
#    param   = "167.128",
#    dataset = "interim",
#    step    = "0",
#    grid    = "0.75/0.75",
#    time    = "00",
#    date    = "2014-07-01/to/2014-07-02",
#    type    = "an",
#    class   = "ei",
#    area    = "73.5/-27/33/45",
#    format  = "netcdf",
#    target  = "tmp.nc"),
#    dynamic_fields = c("area","date"))
#  
#  # change only the date to a single day
#  dynamic_request(date = "2014-07-01")

