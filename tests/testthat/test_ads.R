# set options
options(keyring_backend="file")

# spoof keyring
if(!("ecmwfr" %in% keyring::keyring_list()$keyring)){
  keyring::keyring_create("ecmwfr", password = "test")
}

#opts <- options(keyring_warn_for_env_fallback = FALSE)
#on.exit(options(opts), add = TRUE)
login_check <- NA

ads_request <- list(
  date = "2003-01-01/2003-01-01",
  format = "netcdf",
  variable = "dust_aerosol_optical_depth_550nm",
  time = "00:00",
  dataset_short_name = "cams-global-reanalysis-eac4",
  target = "download.nc"
)

# ignore SSL (server has SSL issues)
httr::set_config(httr::config(ssl_verifypeer = 0L))

# is the server reachable
server_check <- ecmwfr:::ecmwf_running(ecmwfr:::wf_server(service = "ads"))

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(server_check){
  user <-
    try(
      wf_set_key(user = "2161",
                 key = system("echo $ADS", intern = TRUE),
                 service = "ads")
    )
  print(user)
  login_check <- inherits(user, "try-error")
}

#----- formal checks ----

test_that("ads datasets returns data.frame or list", {
  skip_on_cran()
  skip_if(login_check)
  expect_true(inherits(wf_datasets(user = "2161",
                                   service = "ads",
                                   simplify = TRUE), "data.frame"))
  expect_true(inherits(wf_datasets(user = "2161",
                                   service = "ads",
                                   simplify = FALSE), "list"))
})

# Testing the ads request function
test_that("ads request", {
  skip_on_cran()
  skip_if(login_check)

  # ok transfer
  expect_message(wf_request(user = "2161",
                            request = ads_request,
                            transfer = TRUE))
})

# ads product info
test_that("check ADS product info",{
  skip_on_cran()
  skip_if(login_check)
  expect_output(
    str(wf_product_info("cams-global-reanalysis-eac4",
                        service = "ads",
                        user = "2161")))
})

test_that("batch request works", {
  skip_on_cran()
  skip_if(login_check)

  years <- c(2017,2018)

  requests <- lapply(years, function(y) {
    list(
      date = paste0(y, "-01-01"),
      format = "netcdf",
      variable = "dust_aerosol_optical_depth_550nm",
      time = "00:00",
      dataset_short_name = "cams-global-reanalysis-eac4",
      target = sprintf("download%s.nc",y)
    )
  })

  expect_output(wf_request_batch(requests, user = "2161"))
})
