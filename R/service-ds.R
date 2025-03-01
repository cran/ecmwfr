#' @import tools

ds_service <- R6::R6Class("ecmwfr_ds",
  inherit = service,
  public = list(
    submit = function() {
      if (private$status != "unsubmitted") {
        return(self)
      }

      # get key
      key <- wf_get_key(
        user = private$user
      )

      # sanizite request before submission
      # some product requests can't handle the
      # presence of extra fields (e.g. target
      # dataset_short_name)
      request <- private$request
      request$dataset_short_name <- NULL
      request$target <- NULL

      #  get the response for the query provided
      response <- httr::VERB(
        private$http_verb,
        private$request_url(),
        httr::add_headers(
          "PRIVATE-TOKEN" = key
        ),
        body = list(inputs = request),
        encode = "json"
      )

      # trap general http error
      if (httr::http_error(response)) {
        stop(httr::content(response),
          call. = FALSE
        )
      }

      # grab content, to look at the status
      # and code
      ct <- httr::content(response)
      ct$code <- httr::status_code(response)

      # some verbose feedback
      if (private$verbose) {
        message("- staging data transfer at url endpoint or request id:")
        message("  ", ct$jobID, "\n")
        message("  on server: ", wf_server(service = private$service), "\n")
      }

      private$status <- ct$status
      private$code <- ct$code
      private$name <- ct$jobID
      private$next_retry <- Sys.time() + private$retry

      # update url from collection to scheduled job
      private$url <- wf_server(id = ct$jobID, service = private$service)

      return(self)
    },
    update_status = function(
      fail_is_error = TRUE,
      verbose = NULL) {

      if (private$status == "unsubmitted") {
        self$submit()
        return(self)
      }

      if (private$status == "deleted") {
        warn_or_error(
          "Request was previously deleted from queue",
          call. = FALSE,
          error = fail_is_error
          )
        return(self)
      }

      if (private$status == "failed") {
        warn_or_error(
          "Request has failed, please check the online request queue for more details!",
          call. = FALSE,
          error = fail_is_error
        )
        return(self)
      }

      key <- wf_get_key(
        user = private$user
        )

      # set retry time
      retry_in <- as.numeric(private$next_retry) - as.numeric(Sys.time())

      if (retry_in > 0) {
        if (private$verbose) {
          # let a spinner spin for "retry" seconds
          spinner(retry_in)
        } else {
          # sleep
          Sys.sleep(retry_in)
        }
      }

      response <- httr::GET(
        private$url,
        httr::add_headers(
          "PRIVATE-TOKEN" = key
        ),
        encode = "json"
      )

      ct <- httr::content(response)
      private$status <- ct$status

      # trap general http error most likely
      # will fail on spamming the service too fast
      # with a high retry rate
      if (httr::http_error(response)) {
        stop(paste0(
          httr::content(response),
          "--- check your retry rate!"),
          call. = FALSE
        )
      }

      # checks the status of the true download, not the http status
      # of the call itself
      if (private$status != "successful" || is.null(private$status)) {
        private$code <- 202
        private$file_url <- NA # just to be on the safe side
      } else if (private$status == "successful") {
        if (private$verbose) message("   file ready to download...           ")
        private$code <- 302
        private$file_url <- private$get_location(ct)
      } else if (private$status == "failed") {
        private$code <- 404
        permanent <- if (ct$error$permanent) "permanent "
        error_msg <- paste0(
          "Data transfer failed with ", permanent, ct$error$who, " error: ",
          ct$error$message, ".\nReason given: ", ct$error$reason, ".\n",
          "More information at ", ct$error$url
        )
        warn_or_error(error_msg, error = fail_is_error)
      }

      private$next_retry <- Sys.time()
      return(self)
    },

    download = function(
      force_redownload = FALSE,
      fail_is_error = TRUE,
      verbose = NULL
      ) {

      # Check if download is actually needed
      if (private$downloaded == TRUE & !force_redownload) {
        if (private$verbose) message("File already downloaded")
        return(self)
      }

      # Check status
      self$update_status()

      if (private$status != "successful") {
        # if (private$verbose) message("\nRequest not completed")
        return(self)
      }

      # If it's completed, begin download
      if (private$verbose) message("\nDownloading file")

      temp_file <- tempfile(pattern = "ecmwfr_", tmpdir = private$path)
      key <- wf_get_key(user = private$user)

      # formally download the file
      response <- httr::GET(
        private$file_url,
        httr::write_disk(temp_file, overwrite = TRUE),
        if(private$verbose) {httr::progress()}
      )

      # trap (http) errors on download, return a general error statement
      if (httr::http_error(response)) {
        warn_or_error(
          paste0("Download failed with error ", response$status_code),
          call. = FALSE,
          error = fail_is_error
        )
      }

      # flag as downloaded
      private$downloaded <- TRUE

      # no target file provided
      # use temp file name (assignment
      # of extension see below)
      if(length(private$file) ==  0){
        private$file <- temp_file
      }

      # check extension
      if(tools::file_ext(private$file_url) != tools::file_ext(private$file)){

        # list old and new name
        old_file <- private$file
        new_file <- paste0(
          tools::file_path_sans_ext(private$file),".",
          tools::file_ext(private$file_url)
        )

        # assign to internal variable
        private$file <- new_file

        # provide feedback
        if (private$verbose){
          message(
            sprintf(
              "- renaming output format -> %s to %s",
              old_file, new_file
            )
          )
        }
      }

      # Copy data from temporary file to final location
      move <- suppressWarnings(file.rename(temp_file, private$file))

      # check if the move was successful
      # fails for separate disks/partitions
      # then copy and remove
      if (!move) {
        file.copy(temp_file, private$file, overwrite = TRUE)
        file.remove(temp_file)
      }

      if (private$verbose) {
        message(sprintf("- moved temporary file to -> %s", private$file))
      }

      return(self)
    },

    delete = function() {

      # get key
      key <- wf_get_key(user = private$user)

      #  get the response for the query provided
      response <- httr::DELETE(
        private$url,
        httr::add_headers(
          "PRIVATE-TOKEN" = key
        )
      )

      # trap general http error
      if (httr::http_error(response)) {
        stop(httr::content(response),
             call. = FALSE
        )
      }

      # some verbose feedback
      if (private$verbose) {
        message("- Delete data from queue for url endpoint or request id:")
        message("  ", private$url, "\n")
      }

      private$status <- "deleted"
      private$code <- 204
      return(self)
    },

    browse_request = function() {
      url <- paste0(dirname(private$url),"/requests?tab=all")
      utils::browseURL(url)
      return(invisible(self))
    }
  ),
  private = list(
    http_verb = "POST",
    request_url = function() {
      sprintf(
        "%s/retrieve/v1/processes/%s/execute",
        private$url,
        private$request$dataset_short_name
      )
    },
    get_location = function(content) {

      # get key
      key <- wf_get_key(
        user = private$user
      )

      # fetch download location from results URL
      # this is now a two step process
      response <- httr::GET(
        file.path(private$url, "results"),
        httr::add_headers(
          "PRIVATE-TOKEN" = key
        )
      )

      # trap general http error
      if (httr::http_error(response)) {
        stop(httr::content(response),
             call. = FALSE
        )
      }

      # grab content
      ct <- httr::content(response)

      # return the asset location
      return(ct$asset$value$href)

    }
  )
)
