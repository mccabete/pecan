#-------------------------------------------------------------------------------
# Copyright (c) 2012 University of Illinois, NCSA.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the 
# University of Illinois/NCSA Open Source License
# which accompanies this distribution, and is available at
# http://opensource.ncsa.illinois.edu/license.html
#-------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------#
##' Main driver function to call the ecosystem model specific (e.g. ED, SiPNET) 
##' run and configuration file scripts 
##' 
##' @name run.write.configs
##' @title Run model specific write configuration functions
##' @param model the ecosystem model to generate the configuration files for
##' @param write should the runs be written to the database
##' @param ens.sample.method how to sample the ensemble members("halton" sequence or "uniform" random)
##' @param posterior.files Filenames for posteriors for drawing samples for ensemble and sensitivity
##'    analysis (e.g. post.distns.Rdata, or prior.distns.Rdata). Defaults to NA, in which case the 
##'    most recent posterior or prior (in that order) for the workflow is used. Should be a vector, 
##'    with one entry for each PFT. File name only; PFT outdirs will be appended (this forces use of only
##'    files within this workflow, to avoid confusion).
##'
##' @return an updated settings list, which includes ensemble IDs for SA and ensemble analysis
##' @export
##'
##' @author David LeBauer, Shawn Serbin, Ryan Kelly, Mike Dietze
run.write.configs <- function(settings, write = TRUE, ens.sample.method="uniform",
                       posterior.files=rep(NA, length(settings$pfts)), overwrite=TRUE) {

  ## Which posterior to use?
  for(i in seq_along(settings$pfts)){
    ## if posterior.files is specified us that
    if(is.na(posterior.files[i])){
      ## otherwise, check to see if posteriorid exists
      if(!is.null(settings$pfts[[i]]$posteriorid)){
        con <- db.open(settings$database$bety)
        files = dbfile.check("Posterior",settings$pfts[[i]]$posteriorid,con,settings$host$name)
        pid = grep("post.distns.*Rdata",files$file_name)  ## is there a posterior file?
        if(length(pid) == 0){
          pid = grep("prior.distns.Rdata",files$file_name)  ## is there a prior file?
        }
        if(length(pid)>0){
          posterior.files[i] = file.path(files$file_path[pid],files$file_name[pid])
        }  ## otherwise leave posteriors as NA
        db.close(con)
      }
      ## otherwise leave NA and get.parameter.samples will look for local
    }
  }
  
  
  ## Sample parameters
  model = settings$model$type
  scipen = getOption("scipen")
  options(scipen=12)
  get.parameter.samples(settings, posterior.files, ens.sample.method)
  load(file.path(settings$outdir, "samples.Rdata"))

  require(coda)
  ## remove previous runs.txt
  if (overwrite && file.exists(file.path(settings$rundir, "runs.txt"))) {
    logger.warn("Existing runs.txt file will be removed.")
    unlink(file.path(settings$rundir, "runs.txt"))
  }

  load.modelpkg(model)

  ## Check for model-specific write configs

  my.write.config <- paste("write.config.",model,sep="")
  if(!exists(my.write.config)){
    logger.error(my.write.config, "does not exist, please make sure that the model package contains a function called",  my.write.config)
  }

  ## Prepare for model output.  Cleanup any old config files (if exists)
  my.remove.config <- paste0("remove.config.",model)
  if(exists(my.remove.config)) {
    do.call(my.remove.config, args = list(settings$rundir, settings))
  }

  
  # TODO RK : need to write to runs_inputs table

  # Save names
  pft.names <- names(trait.samples)
  trait.names <- lapply(trait.samples, names)

  
  ### NEED TO IMPLEMENT: 
  ## Load Environmental Priors and Posteriors
  
  ### Sensitivity Analysis
  if('sensitivity.analysis' %in% names(settings)) {

    ### Write out SA config files
    if(!exists("cnt")) {            
      cnt <- 0
      assign("cnt", cnt, .GlobalEnv)
    }
    logger.info("\n ----- Writing model run config files ----")
    sa.runs <- write.sa.configs(defaults = settings$pfts,
                                        quantile.samples = sa.samples,
                                        settings = settings,
                                        model = model,
                                        write.to.db = write)

    # Store output in settings and output variables
    runs.samples$sa <- sa.run.ids <- sa.runs$runs
    settings$sensitivity.analysis$ensemble.id <- sa.ensemble.id <- sa.runs$ensemble.id

    # Save sensitivity analysis info
    fname <- sensitivity.filename(settings, "sensitivity.samples", "Rdata", all.var.yr=TRUE, pft=NULL)
    save(sa.run.ids, sa.ensemble.id, sa.samples, pft.names, trait.names, file=fname)

  } ### End of SA
  
  ### Write ENSEMBLE
  if('ensemble' %in% names(settings)){
        ens.runs <- write.ensemble.configs(defaults = settings$pfts,
                                                    ensemble.samples = ensemble.samples,
                                                    settings = settings,
                                                    model = model,
                                                    write.to.db = write)

    # Store output in settings and output variables
    runs.samples$ensemble <- ens.run.ids <- ens.runs$runs
    settings$ensemble$ensemble.id <- ens.ensemble.id <- ens.runs$ensemble.id
    ens.samples <- ensemble.samples # rename just for consistency
    
    # Save ensemble analysis info
    fname <- ensemble.filename(settings, "ensemble.samples", "Rdata", all.var.yr=TRUE)
    save(ens.run.ids, ens.ensemble.id, ens.samples, pft.names, trait.names, file=fname)
  } else {
    logger.info('not writing config files for ensemble, settings are NULL')
  } ### End of Ensemble

  logger.info("###### Finished writing model run config files #####")
  logger.info("config files samples in ", file.path(settings$outdir, "run"))
  
  ### Save output from SA/Ensemble runs
  # A lot of this is duplicate with the ensemble/sa specific output above, but kept for backwards compatibility. 
  save(ensemble.samples, trait.samples, sa.samples, runs.samples,  pft.names, trait.names,
       file = file.path(settings$outdir, 'samples.Rdata'))
  logger.info("parameter values for runs in ", file.path(settings$outdir, "samples.RData"))
  options(scipen=scipen)
  
  invisible(settings)
}
#==================================================================================================#


##' @export
runModule.run.write.configs <- function(settings, overwrite=TRUE) {
  if(is.MultiSettings(settings)) {
    if (overwrite && file.exists(file.path(settings$rundir, "runs.txt"))) {
      logger.warn("Existing runs.txt file will be removed.")
      unlink(file.path(settings$rundir, "runs.txt"))
    }
    return(papply(settings, runModule.run.write.configs, overwrite=FALSE))
  } else if (is.Settings(settings)) {
    write <- settings$database$bety$write
    ens.sample.method <- settings$ensemble$method
    return(run.write.configs(settings, write, ens.sample.method, overwrite=overwrite))
  } else {
    stop("runModule.run.write.configs only works with Settings or MultiSettings")
  }
}
 
####################################################################################################
### EOF.  End of R script file.          		
####################################################################################################
