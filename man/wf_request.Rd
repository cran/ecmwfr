% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wf_request.R, R/wf_request_batch.R
\name{wf_request}
\alias{wf_request}
\alias{wf_request_batch}
\title{ECMWF data request and download}
\usage{
wf_request(
  request,
  user,
  transfer = TRUE,
  path = tempdir(),
  time_out = 3600,
  job_name,
  verbose = TRUE
)

wf_request_batch(
  request_list,
  workers = 2,
  user,
  path = tempdir(),
  time_out = 3600,
  total_timeout = length(request_list) * time_out/workers
)
}
\arguments{
\item{request}{nested list with query parameters following the layout
as specified on the ECMWF APIs page}

\item{user}{user (email address) used to sign up for the ECMWF data service,
used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}}

\item{transfer}{logical, download data TRUE or FALSE (default = TRUE)}

\item{path}{path were to store the downloaded data}

\item{time_out}{how long to wait on a download to start (default =
\code{3*3600} seconds).}

\item{job_name}{optional name to use as an RStudio job and as output variable
name. It has to be a syntactically valid name.}

\item{verbose}{show feedback on processing}

\item{request_list}{a list of requests that will be processed in parallel.}

\item{workers}{maximum number of simultaneous request that will be submitted
to the service. Most ECMWF services are limited to 20 concurrent requests
(default = 2).}

\item{total_timeout}{overall timeout limit for all the requests in seconds.}
}
\value{
the path of the downloaded (requested file) or the an R6 object
with download/transfer information
}
\description{
Stage a data request, and optionally download the data to disk. Alternatively
you can only stage requests, logging the request URLs to submit download
queries later on using \code{\link[ecmwfr]{wf_transfer}}.
Note that the function will do some basic checks on the \code{request} input
to identify possible problems.
}
\details{
Two sorts of requests are accepted, a simple data request based upon the
available data in the (raw) CDS repository, and a workflow request which
forwards an anonymous python function to the CDS servers and returns its
results.

The latter advanced use case is non-trivial, as both python and R code is
required. However, it allows you to offload costly data operations /
aggregation to the ECMWF servers, therefore limiting the amount of data
that needs to be transferred.

A detailed summary of the use of the python API underpinning the CDS Toolbox
(Editor) these operations is beyond the scope of this package. We refer to
the [CDS Toolbox manual](https://cds.climate.copernicus.eu/toolbox/doc/api.html),
and the small example included in the
[vignettes](https://bluegreen-labs.github.io/ecmwfr/articles/cds_workflow_vignette.html).
}
\examples{

\dontrun{
# set key
wf_set_key(user = "test@mail.com", key = "123")

request <- list(stream = "oper",
   levtype = "sfc",
   param = "167.128",
   dataset = "interim",
   step = "0",
   grid = "0.75/0.75",
   time = "00",
   date = "2014-07-01/to/2014-07-02",
   type = "an",
   class = "ei",
   area = "50/10/51/11",
   format = "netcdf",
   target = "tmp.nc")

# demo query
wf_request(request = request, user = "test@mail.com")

# Run as an RStudio Job. When finished, will create a
# variable named "test" in your environment with the path to
# the downloaded file.
wf_request(request = request, user = "test@mail.com", job_name = "test")
}
}
\seealso{
\code{\link[ecmwfr]{wf_set_key}}
\code{\link[ecmwfr]{wf_transfer}}
}
\author{
Koen Hufkens
}
