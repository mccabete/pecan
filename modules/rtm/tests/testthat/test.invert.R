# Test slow inversion
library(PEcAnRTM)
library(testthat)
context("PROSPECT R inversion")
data(sensor.rsr)
params <- c(1.4, 40, 8, 0.01, 0.01)
obs.raw <- prospect(params, 5)[,1] + generate.noise()
sensor <- "chris.proba"
obs <- spectral.response(obs.raw, sensor)
settings <- default.settings.prospect
settings$model <- function(params) spectral.response(prospect(params,5)[,1], sensor)
settings$ngibbs <- 5000
settings$burnin <- 4000
settings$do.lsq.first <- TRUE
settings$n.tries <- 1
settings$nchains <- 3
#test <- invert.auto(obs, settings, return.samples=TRUE, save.samples=NULL, quiet=FALSE)
#test_that("Inversion output is list of length 2", {
              #expect_is(test, "list")
              #expect_equal(length(test), 2)
#})

test.parallel <- invert.auto(obs, settings, return.samples=TRUE, save.samples=NULL, quiet=TRUE, parallel=TRUE)
test_that("Parallel inversion output is list of length 2", {
              expect_is(test.parallel, "list")
              expect_equal(length(test.parallel), 2)
})

test_that("Parallel inversion output produces distinct chains", {
              expect_false(identical(test.parallel$samples[[1]],
                                     test.parallel$samples[[2]]))
})
