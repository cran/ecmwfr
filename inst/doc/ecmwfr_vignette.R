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
  wf_set_key(email = "khrdev@outlook.com",
             key = system("echo $KEY", intern = TRUE))
}
rm(key)

# check cran, same routine as skip_on_cran()
# but not dependent on testthat which might
# not be available on user systems (not required
# only suggested)
check_cran <- function() {
  key <- try(wf_get_key("khrdev@outlook.com"))
  if (identical(tolower(Sys.getenv("NOT_CRAN")), "true") &
      !inherits(key, "try-error")){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# do cran check
cran <- check_cran()

# for local render force to true
# mainly important for rendering
# a website using pkgdown
#cran <- TRUE

## ----eval = FALSE--------------------------------------------------------
#  # set a key to the keychain
#  wf_set_key(email = "khrdev@outlook.com",
#             key = "XXXXXXXXXXXXXXXXXXXXXX")
#  
#  # you can retrieve the key using
#  wf_get_key(email = "khrdev@outlook.com")
#  
#  # the output should be the key you provided
#  # in this case represented by the fake X string.
#  # "XXXXXXXXXXXXXXXXXXXXXX"

## ----eval = cran---------------------------------------------------------
#  # user info
#  user_info <- wf_user_info(email = "khrdev@outlook.com")
#  head(user_info)
#  
#  # services
#  services <- wf_services(email = "khrdev@outlook.com")
#  head(services)
#  
#  # datasets
#  datasets <- wf_datasets(email = "khrdev@outlook.com")
#  head(datasets)

## ----eval = cran---------------------------------------------------------
#  # this is an example of a request
#  my_request <- list(stream = "oper",
#                    levtype = "sfc",
#                    param = "167.128",
#                    dataset = "interim",
#                    step = "0",
#                    grid = "0.75/0.75",
#                    time = "00",
#                    date = "2014-07-01/to/2014-07-31",
#                    type = "an",
#                    class = "ei",
#                    area = "73.5/-27/33/45",
#                    format = "netcdf",
#                    target = "tmp.nc")
#  
#  # an example download using fw_request()
#  # using the above request list()
#  wf_request(
#    email = "khrdev@outlook.com",
#    transfer = TRUE,
#    path = "~",
#    request = my_request,
#    verbose = FALSE)

## ----fig.width = 7, fig.height = 7, eval = cran--------------------------
#  s <- raster::stack("~/tmp.nc")
#  print(s)
#  
#  raster::plot(s[[1]], main = "2 meter temperature (Kelvin)")
#  maps::map("world", add = TRUE)

