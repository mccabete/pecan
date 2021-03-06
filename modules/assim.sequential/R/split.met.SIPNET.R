## split clim file into smaller time units to use in KF
##' @title split.met.SIPNET
##' @name  split.met.SIPNET
##' @author Mike Dietze
##' 
##' @param met SIPNET met
##' @description Splits climate met for SIPNET
##' 
##' @return files split up climate files
##' @export
##' 
split.met.SIPNET <- function(met){
  
  path <- dirname(met)
  prefix <- sub(".clim","",basename(met),fixed=TRUE)
  dat <- read.table(met,header=FALSE)
  years <- as.numeric(unique(dat[,2]))
  files <- rep(NA,length(years))
  names(files) <- years
  for(y in years){
    sel <- which(dat[,2] == y)
    files[as.character(y)] <- paste(path,"/",prefix,".",y,".clim",sep="") 
    write.table(dat[sel,],files[as.character(y)],row.names=FALSE,col.names=FALSE)
  }
  return(files)
  
}
