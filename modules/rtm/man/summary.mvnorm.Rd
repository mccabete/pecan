% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/process-output.R
\name{summary.mvnorm}
\alias{summary.mvnorm}
\title{Multivariate normal fit}
\usage{
\method{summary}{mvnorm}(samples)
}
\arguments{
\item{samples}{Matrix of MCMC samples.}
}
\description{
Fit multivariate normal to samples. Return means and covariance 
matrix as a long list (for easy construction of data.tables)
}

