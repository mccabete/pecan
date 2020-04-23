<?php

# Information to connect to the BETY database
$db_bety_type="pgsql";
$db_bety_hostname="128.197.168.114";
$db_bety_username="bety";
$db_bety_password="bety";
$db_bety_database="bety";

# Information to connect to the FIA database
# leave this blank if you do not have the FIA database installed.
$db_fia_type="pgsql";
$db_fia_hostname="";
$db_fia_username="";
$db_fia_password="";
$db_fia_database="";

# browdog information
$browndog_url="http://dap.ncsa.illinois.edu:8184/convert/";
$browndog_username="browndog.user";
$browndog_password="GritGin3";

# R binary
$Rbinary="/usr/bin/R";

# sshTunnel binary
$SSHtunnel=dirname(__FILE__) . DIRECTORY_SEPARATOR . "sshtunnel.sh";

# google map key
$googleMapKey="";

# Require username/password, can set min level to 0 so nobody can run/delete.
# 4 = viewer
# 3 = creator
# 2 = manager
# 1 = administrator
$authentication=false;
$min_run_level=2;
$min_delete_level=2;

# Used for authentication, needs to be same as ruby
$REST_AUTH_SITE_KEY="thisisnotasecret";
$REST_AUTH_DIGEST_STRETCHES =10;

# anonymous access level
$anonymous_level = 99;
$anonymous_page = 99;

# name of current machine
$fqdn=exec('hostname -f');

# List of all host and options. The list should be the server pointing
# to an array. The second array contains a key value pair used to 
# configure the host. Currenly the following options are available:
# - qsub       : if specified the jobs are launched using qsub, this can
#                be an empty value to indicate to use default settings.
#                If not specified jobs are run on the host itself.
# - jobid      : regex used to parse jobid, only used if qsub specified.
# - qstat      : command used to check if job submitted using qsub is
#                finished.
# - launcher   : path to modellauncher, used to for a single job that
#                consists of many smaller jobs
# - job.sh     : any special parameters to add to the job.sh file. (deprecated)
# - prerun     : any special options to add at the begging of the job.
# - postrun    : any special options to add at the end of the job.
# - folder     : folder on remote machine, will add username and the
#                workflowid to the folder name
# - models     : any special options to add to a specific model that is 
#                launched. This is an array of the modeltype and
#                additional parameters for the job.sh.
# - scratchdir : folder to be used for scratchspace when running certain
#                models (such as ED)
# Prvious Module load (4/13/2020) "module load udunits/2.2.26 R/3.5.1" array("prerun"  => "module purge; #hdf5/1.8.21"))));
$hostlist=array($fqdn => array(), "pecan2.bu.edu" => array(),
                "geo.bu.edu" => 
                    array("qsub"   => "qsub -l buyin -l h_rt=48:00:00 -q 'geo*' -N @NAME@ -o @STDOUT@ -e @STDERR@ -S /bin/bash",
                          "jobid"   => "Your job ([0-9]+) .*",
                          "qstat"   => "qstat -j @JOBID@ || echo DONE",
                          "prerun"  => "module load udunits/2.2.26 R/3.6.0", 
                          "folder" => "/projectnb/dietzelab/pecan.data/output/",
                          "models"  => array("ED2" =>
                              array("prerun"  => "module purge; module load hdf5/1.8.21"))));

# Folder where PEcAn is installed
$R_library_path="/fs/data3/tmccabe/R/newlib/"; #$R_library_path="/fs/data3/ecowdery/R/library/"; #
# Location where PEcAn is installed, not really needed anymore
# $pecan_home="/fs/data3/ecowdery/pecan/";

# Folder where the runs are stored
$output_folder="/fs/data2/output/";

# Folder where the generated files are stored
$dbfiles_folder="/fs/data1/pecan.data/dbfiles/";

# location of BETY DB set to empty to not create links, can be both
# relative or absolute paths or full URL's. Should point to the base
# of BETYDB
$betydb="http:/psql-pecan.bu.edu/bety/";

# ----------------------------------------------------------------------
# SIMPLE EDITING OF BETY DATABSE
# ----------------------------------------------------------------------
# Number of items to show on a page
$pagesize = 30;

# Location where logs should be written
$logfile = "/home/carya/output/betydb.log";

# uncomment the following variable to enable the simple interface
#$simpleBETY = TRUE;


?>
