###############################
# Sample size
###############################
#' Sample size calculation
#'
#' @details See \url{http://mostly-harmless.github.io/radiant/quant/sample_size.html} for an example in Radiant
#'
#' @param smp_sample_size Number of units to select
#'
#' @return A list of variables defined in sample_sizze as an object of class sample_size
#'
#' @examples
#' result <- sample_size(ss_type = "mean", ss_mean_err = 2, ss_mean_s = 10)
#'
#' @seealso \code{\link{summary.sample_size}} to summarize results
#' @export
sample_size <- function(ss_type = "mean",
                        ss_mean_err = 2,
                        ss_mean_s = 10,
                        ss_prop_err = .1,
                        ss_prop_p = .5,
                        ss_z = 1.96,
                        ss_incidence = 1,
                        ss_response = 1,
                        ss_pop_correction = "no",
                        ss_pop_size = 1000000) {

	if(ss_type == 'mean') {
		if(is.na(ss_mean_err)) return("Please select an error value greater 0.")

		n <- (ss_z^2 * ss_mean_s^2) / ss_mean_err^2
	} else {

		if(is.na(ss_prop_err)) return("Please select an error value greater 0.")
		n <- (ss_z^2 * ss_prop_p * (1 - ss_prop_p)) / ss_prop_err^2
	}

	if(ss_pop_correction == 'yes')
		n <- n * ss_pop_size / ((n - 1) + ss_pop_size)

	n <- ceiling(n)

  environment() %>% as.list %>% set_class(c("sample_size",class(.)))
}

#' Summary method for sample size calculation
#'
#' @details See \url{http://mostly-harmless.github.io/radiant/quant/sample_size} for an example in Radiant
#'
#' @param result Return value from \code{\link{sample_size}}
#'
#' @examples
#' result <- sample_size(ss_type = "mean", ss_mean_err = 2, ss_mean_s = 10)
#' summary(result)
#'
#' @seealso \code{\link{sampling}} to generate the results
#'
#' @export
summary.sample_size <- function(result) {
	cat("Sample size calculation\n")

	if(result$ss_type == "mean") {
	  cat("Calculation type     : Mean\n")
		cat("Acceptable Error     :", result$ss_mean_err, "\n")
		cat("Sample std. deviation:", result$ss_mean_s, "\n")
	} else {
	  cat("Type: Proportion\n")
		cat("Acceptable Error     :", result$ss_prop_err, "\n")
		cat("Sample proportion    :", result$ss_prop_p, "\n")
	}

	cat("Confidence level     :", result$ss_z, "\n")
	cat("Incidence rate       :", result$ss_incidence, "\n")
	cat("Response rate        :", result$ss_response, "\n")

	if(result$ss_pop_correction == "no") {
		cat("Population correction: None\n")
	} else {
		cat("Population correction: Yes\n")
		cat("Population size      :", format(result$ss_pop_size, big.mark = ",",
		    																 scientific = FALSE), "\n")
	}

	cat("\nRequired sample size     :", format(result$n, big.mark = ",",
	    																			 scientific = FALSE))
	cat("\nRequired contact attempts:", format(ceiling(result$n / result$ss_incidence / result$ss_response),
	    																			 big.mark = ",", scientific = FALSE))
	cat("\n\nChoose a Z-value:\n")

  for(z in c(.80, .85, .90, .95, .99))
    cat(paste0(100*z,"%\t"),-qnorm((1-z)/2) %>% round(2),"\n")

  rm(result)
}
