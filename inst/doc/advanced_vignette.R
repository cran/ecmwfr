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

# import the encrypted key if desired
# (does not exist locally)
key <- system("echo $KEY", intern = TRUE)
if(key != "" & key != "$KEY"){
  wf_set_key(user = "khrdev@outlook.com",
             key = key,
             service = "webapi")
}
rm(key)

# check cran, same routine as skip_on_cran()
# but not dependent on testthat which might
# not be available on user systems (not required
# only suggested)
check_cran <- function() {
  key <- try(wf_get_key("khrdev@outlook.com"))
  if (!inherits(key, "try-error")){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# do cran check
cran <- check_cran()

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

## ----eval = TRUE---------------------------------------------------------
# this is an example of a request
dynamic_request <- wf_archetype(request = list(
  stream  = "oper",
  levtype = "sfc",
  param   = "167.128",
  dataset = "interim",
  step    = "0",
  grid    = "0.75/0.75",
  time    = "00",
  date    = "2014-07-01/to/2014-07-02",
  type    = "an",
  class   = "ei",
  area    = "73.5/-27/33/45",
  format  = "netcdf",
  target  = "tmp.nc"),
  dynamic_fields = c("area","date"))

# change only the date to a single day
dynamic_request(date = "2014-07-01")

