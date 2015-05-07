#! /usr/local/bin/csi -s
;; ##################################################################
;;
;; MassMine: Your Access To Big Data
;; Copyright (C) 2014-2015  Nicholas M. Van Horn & Aaron Beveridge
;; 
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;; x.x.x 2015-05-01 NVH: Initial chicken version
;;
;; Instructions: See www.massmine.org for complete documentation and
;; instructions for how to use massmine

;; WARNING @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;; You are working in the chicken branch of this git repo

;; (declare (uses massmine-twitter))

;; Extensions
(require-extension args clucker)

;; Load massmine modules. This only occurs during interpreted
;; evaluation. These modules are linked when compiled for compiled
;; code 
;; (eval-when (eval)
;; 	   (load "./modules/twitter.scm"))

;; (eval-when (eval)
;; 	   (import massmine-twitter))

;; (eval-when (compile)
;; 	   (include "modules/twitter")
;; 	   (import massmine-twitter))

(include "./modules/twitter")
(import massmine-twitter)
(import clucker)

;; Current version of software
;; mm_version = 'x.x.x (2015-05-01)'
(define mm-version "x.x.x (2015-05-01)")

;;; The following list contains all defined command line options
;;; available to the user. For example, (h help) makes all of the
;;; following equivalent options available at runtime: -h, -help, --h,
;;; --help. These are used by the "args" egg.
(define opts
  (list (args:make-option (h help)    #:none "Help information"
			  (usage))
	(args:make-option (v version)  #:none "Version information"
			  (print-version))
	(args:make-option (output)  (required: "FILE")  "Write to file"
			  (set! output-to-file? #t))
	(args:make-option (pattern)  (required: "KEYWORDS") "Keyword(s)"
			  (set! keywords #f))
	(args:make-option (count)  (required: "NUM") "Number of records"
			  (set! max-tweets #f))
	(args:make-option (time)  (required: "SECOND") "Duration"
			  (set! global-max-seconds #f))
	(args:make-option (geo)  (required: "COORDINATE") "Location"
			  (set! locations #f))
	(args:make-option (lang)  (required: "LANG") "Language"
			  (set! locations #f))
	(args:make-option (no-splash)  #:none "Inhibit splash screen"
			  (set! do-splash? #f))
	))

;;; This procedure is called whenever the user specifies the help
;;; option at runtime OR whenever an unexpected command line option or
;;; operand is passed to this script.
(define (usage)
 (with-output-to-port (current-error-port)
   (lambda ()
     (print "Usage: massmine ... [options...]")
     (newline)
     (print (args:usage opts))
     (print "Retrieve and store data from web sources")
     (newline)
     (print "Report bugs to nemo1211 at gmail.")))
 (exit 1))

;; Prints the current version of massmine, and useful info
(define (print-version)
  (print "massmine " mm-version)
  (print "https://github.com/n3mo/massmine")
  (newline)
  (print "Copyright (C) 2014-2015 Nicholas M. Van Horn & Aaron Beveridge")
  (print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.")
  (print "This is free software: you are free to change and redistribute it.")
  (print "There is NO WARRANTY, to the extent permitted by law.")
  (exit 0))

;; This script behaves differently depending on whether it is called
;; interactively or as a script
;; interactivep = interactive()

;; Credentials are still managed transparently for the user, who
;; presumably doesn't want to think about such
;; things. Pre-authenticated accounts are stored in a more traditional
;; *nix location. If the configuration directory doesn't exist, it is
;; created at startup
;; mm_cred_path = "~/.config/massmine"
;; if (!file.exists(mm_cred_path)) {
;;   dir.create(mm_cred_path, showWarnings = TRUE, recursive = TRUE)
;; } 

;; Parse command line arguments. Currently, massmine only supports a
;; single argument: The user can specify the path to the configuration
;; file. If no file path is supplied, the default config file is
;; used. If you're running massmine manually inside of R, the
;; installation directory will not be detected properly. Users
;; shouldn't be doing this though. They should be calling massmine
;; directly from a terminal.
;; if (interactivep) {
;;   mm_install_dir = "."
;; } else {
;;   initial.options = commandArgs(trailingOnly = FALSE)
;;   file.arg.name = "--file="
;;   massmine.path = sub(file.arg.name, "",
;;     initial.options[grep(file.arg.name, initial.options)])
;;   ## This is the installation location for massmine on the current
;;   ## machine. Loading of modules should be done relative to this path
;;   mm_install_dir = dirname(massmine.path)
;; }

;; MassMine modules are installed relative to the above directory
;; mm_module_dir = file.path(mm_install_dir, "R")

;; As of 2014-11-12, massmine looks in the current working directory
;; for a configuration file called mmconfig. If it can't find it, it
;; looks for a folder called "examples" in the massmine installation
;; directory and searches there for the same file. If that fails,
;; massmine quits and complains to the user. Of course, the user can
;; avoid all of this by simply including the path to a config file at
;; runtime ("massmine ~/.../mmconfig)
;; default_config_file = file.path(".", 'mmconfig')
;; backup_config_file = file.path(mm_install_dir, "examples", 'mmconfig')

;; MassMine saves twitter credentials across sessions. A file will be
;; created at the following location with the OAuth information for
;; your account. The next time you run massmine, you will not need to
;; authenticate manually (unless you wish to switch to another twitter
;; account)
;; default_twit_file = file.path(mm_cred_path, 'mm_twitter_credentials')

;; Required packages. These dependencies must be installed at the
;; system OR user level. MassMine checks for these before running,
;; offering to install missing deps for the user.
;; mm_deps = c('ROAuth', 'twitteR', 'streamR', 'zoo', 'stringr', 'yaml')
;; mm_deps = c('ROAuth', 'twitteR', 'stringr', 'yaml', 'rjson', 'tools')

;; Data mining services currently supported by MassMine
;; mm_services = c('twitter')

;; mmConfig <- function(config_file) {
;;   ## Checks for, creates, and ultimately processes the user
;;   ## configuration file that controls massmine's behavior. config_file
;;   ## is a file path pointing to a YAML structured user configuration
;;   ## file 
;;   if (file.exists(config_file)) {
    
;;     config = yaml.load_file(config_file)

;;     ## Some configuration parameters are optional. We set their
;;     ## default values here 

;;     ## Required twitter parameters:
;;     if ("twitter" %in% names(config)) {
;;       if (!"twit_file" %in% names(config$twitter)) {
;;         config$twitter$twit_file = default_twit_file
;;       }
;;     }

;;     ## We're done. Return the configuration list.
;;     return(config)

;;   } else {

;;     ## No user configuration file detected. Warn the user and abort
;;     stop('No configuration file found. MassMine stopped\n', call.=FALSE)

;;   }
;; }

;; saveData <- function(tweets, filename, append=TRUE,
;;                      logfile = stdout()) {
;;   ## This saves any data frame to a CSV file. This is just a wrapper
;;   ## around the function write.table() that manages the optional
;;   ## arguments for us. "tweets" is a properly-formed data frame as
;;   ## returned by getimeline or searchTweets. "filename" is a string
;;   ## containing the file name (and option file path) that you would
;;   ## like to save the data frame to.

;;   ## This does all the real work. 
;;   ## write.table(tweets, file=filename, row.names=F, append=append,
;;   ##             col.names=TRUE, sep=",")
;;   write.csv(tweets, file=filename, row.names=FALSE)

;;   ## Friendly message letting you know it worked
;;   cat(sprintf("Database saved to %s\n", filename), file = logfile,
;;       append = TRUE)
  
;; } ## End of function saveData

;; loadData <- function(filename) {
;;   ## This function loads twitter data stored on disk that was written
;;   ## previously with the function saveData. The data are loaded into a
;;   ## data frame (identical in form to data frames returned by
;;   ## getTimeline and searchTweets) and columns are coerced into
;;   ## appropriate object classes. The resulting data frame is
;;   ## returned. "filename" is the name of the file (and optionally the
;;   ## file path) of the twitter data file you would like to load

;;   read.table(filename, header=T, sep=",")
;; } ## End of function loadData

;; getResponse <- function(msg, resp) {
;;   ## A convenience function for requesting input from the user. Given a
;;   ## message "msg" and a list of possible responses "resp", getResponse
;;   ## prompts the user with msg and collects their response. If an
;;   ## invalid response is given, the process is repeated until a valid
;;   ## response is obtained. getResponse also attempts to check if
;;   ## massmine has been called in an interactive environment or as a
;;   ## script, calling the appropriate readline/readLines function
;;   ## accordingly. 

;;   N_resp = length(resp)
;;   ## The method of interacting with the user depends on whether
;;   ## massmine was called interactively
;;   if (interactive()) {
;;     readFun = function() readline()
;;   } else {
;;     readFun = function() readLines(file("stdin"), 1)
;;   }

;;   while (TRUE) {
;;     cat(paste(msg, '\n', sep=''))
;;     ## cat('Enter one of the following options:\n')

;;     ## Present the user with valid response options. The original
;;     ## method below numbered each option. This created the expectation
;;     ## that responses could be numeric, so I removed the automatic
;;     ## numbering. 
;;     ## cat(paste(' <Option ', 1:N_resp, '> ', resp, sep=''), sep='\n')
;;     cat(paste(' <Option> ', resp, sep=''), sep='\n')

;;     ## Collect the response
;;     cat('Choose => ')
;;     userResp = readFun()

;;     ## Check if the response is valid. If it is, return the
;;     ## response. Otherwise, repeat.
;;     if (is.na(userResp) | !tolower(userResp) %in% tolower(resp)) {
;;       ## Do nothing... just repeat
;;     } else {
;;       return(userResp)
;;     }
;;   }
;; } ## End of function getResponse

;; loadModules <- function(config, module_directory) {
;;   ## For every service requested, the corresponding module is loaded
;;   ## into memory from the directory module_directory

;;   ## Twitter?
;;   if (any(config$service == tolower("twitter"))) {
;;     source(file.path(mm_module_dir, "twitter.R"))
;;   }
  
;; } ## End of function loadModules

;; taskDispatch <- function(config) {
;;   ## During noninteractive sessions, this parses the user's
;;   ## configurations and calls the appropriate internal functions

;;   ## This list maps YAML style config tasks to internal massmine
;;   ## service functions.
;;   twitter_tasks = list(
;;     test = "mmTest",
;;     locations = "getTrendLocations",
;;     timeline = "fetchUsers",
;;     trends = "monitorTrends",
;;     stream = "streamFilter",
;;     search = "restSearch"
;;     )

;;   ## TODO: add verification method for ensuring that the user has
;;   ## chosen a valid task and valid options

;;   ## The service(s) the user has requested
;;   user_services = config$service

;;   ## Currently MassMine only supports ONE service at a time. Even
;;   ## though the logically-above code allows for multiple services,
;;   ## they are pruned away if present at this point. Only the first
;;   ## service listed in the user's config file is retained from here
;;   ## forward. 
  
;;   user_task = config[[user_services[1]]]$task

;;   ## The options the user has requested for the current task
;;   user_options = config[[user_services[1]]]$options

;;   ## Convert task request to internal function
;;   user_function = unlist(twitter_tasks[user_task])

;;   ## Notify stdout of impending job
;;   cat(sprintf('Running function %s...\n', user_function))

;;   ## Dispatch according to the user's task and options. THIS CALL GETS
;;   ## THE JOB DONE
;;   do.call(user_function, user_options)
  
;; } ## End of function taskDispatch

;; upgradeMassmine <- function(doPackages = mm_deps) {
;;   ## Run this for side effects. This attempts to install/update all
;;   ## required dependencies for MassMine.

;;   cat("\nUpgrading MassMine dependencies...\n")
;;   userdir <- unlist(strsplit(Sys.getenv("R_LIBS_USER"), 
;;                              .Platform$path.sep))[1L]
;;   if (!file.exists(userdir)) {
;;     ## Create the user's local R library directory if it isn't here
;;     dir.create(userdir, recursive = TRUE)
;;   } 
;;   install.packages(mm_deps,
;;                    lib = userdir,
;;                    repos = "http://cran.us.r-project.org")
;;   cat('Upgrade complete!\n')
;;   stop('Restart MassMine to begin', call.=FALSE)

;; } ## End of function upgradeMassmine

;; ##################################################################
;; AUTO RUN
;; ##################################################################
;; Everything below here controls the behavior of massmine when it is
;; ran (either interactively or as a script)

;; ##################################################################
;; Splash Screen
;; ##################################################################
;; Software info pretty-printed for the user
(define (splash-screen)
  (print "\n"
	 "        __  __               __  __ _                     \n"
	 "       |  \\/  | __ _ ___ ___|  \\/  (_)_ __   ___        \n"
	 "       | |\\/| |/ _` / __/ __| |\\/| | | \"_ \\ / _ \\    \n"
	 "       | |  | | (_| \\__ \\__ \\ |  | | | | | |  __/      \n"
	 "       |_|  |_|\\__,_|___/___/_|  |_|_|_| |_|\\___|       \n"
	 "                                                          \n"
	 "                Your Access To Big Data                   \n"
	 "\n\n"
	 "MassMine version " mm-version "\n"
	 "https://github.com/n3mo/massmine\n\n"
	 "Copyright (C) 2014-2015 Nicholas M. Van Horn & Aaron Beveridge\n"
	 "This program comes with ABSOLUTELY NO WARRANTY.\n"
	 "This is free software, and you are welcome to redistribute it\n"
	 "under certain conditions. Please see the included LICENSE file\n"
	 "for more information\n\n"))

;; ##################################################################
;; Load dependencies
;; ##################################################################
;; Check if all required libraries are installed. If not, exit and
;; inform the user of which libraries need to be installed. If all are
;; installed, load them and move on.

;; Vector of installed packages
;; allPkg = installed.packages()[,1]

;; Check if each dependency is installed
;; is_installed = sapply(mm_deps, function(x) is.element(x, allPkg))

;; If anything is missing, stop and warn the user
;; if (!all(is_installed)) {
;;   cat('Dependencies missing!\n',
;;       'You must install the following R packages\n',
;;       'before continuing: ',
;;       paste(mm_deps[!is_installed], collapse=', '),
;;       '\n')

;;   cat('MassMine can attempt to install these for you.\n')
;;   resp = getResponse('Would you like to try now?', c('Yes', 'No'))

;;   if (tolower(resp) == 'yes') {
;;     cat('Attempting install with your default settings...\n')
;;     userdir <- unlist(strsplit(Sys.getenv("R_LIBS_USER"), 
;;                                    .Platform$path.sep))[1L]
;;     if (!file.exists(userdir)) {
;;         ## Create the user's local R library directory if it isn't here
;;         dir.create(userdir, recursive = TRUE)
;;     } 
;;     install.packages(mm_deps[!is_installed],
;;                      lib = userdir,
;;                      repos = "http://cran.us.r-project.org")
;;     cat('Installation complete!\n')
;;     stop('Restart MassMine to begin', call.=FALSE)
;;   } else {
;;     stop('Please install dependencies before continuing',
;;          call. = FALSE)
;;   }
;; }

;; If we've made it here, all necessary dependencies are
;; installed. Load them now
;; suppressPackageStartupMessages(

;;   ## I hate for loops...
;;   for (dep in mm_deps) {
;;     require(dep, quietly = TRUE, warn.conflicts = FALSE,
;;             character.only = TRUE)
;;   })

;; For unknown reasons, the built-in methods package doesn't load when
;; running with RScript. This gets things running.
;; suppressPackageStartupMessages(require(methods))

;; If massmine was called as a script (the preferred method), then the
;; readline function used by many packages is broken. You must use
;; readLines() instead. Here, we simply redefine the function once and
;; for all under such circumstances
;; if (!interactivep) {
;;   my.readline <- function(...) {cat("It worked!", ...); readLines(file("stdin"), 1)}
;;   unlockBinding("ROAuth::readline", as.environment("package:ROAuth"))
;;   assign("ROAuth::readline", my.readline, as.environment("package:ROAuth"))
;;   lockBinding("ROAuth::readline", as.environment("package:ROAuth"))
;; } 

;; args = commandArgs(TRUE)
;; if (is.na(args[1])) {
;;   ## The user has not supplied a path to a configuration file at
;;   ## runtime. We now search locally
;;   if (file.exists(default_config_file)) {
;;     config_file = default_config_file
;;   } else if (file.exists(backup_config_file)) {
;;     config_file = backup_config_file
;;   } else {
;;     stop('No configuration file found. MassMine stopped\n',
;;          call.=FALSE)
;;   }
;; } else {
;;   ## User has supplied command-line arguments. Check them and act
;;   ## accordingly
;;   if (args[1] == "upgrade") {
;;     ## The user has asked for a forced upgrade of dependencies. This
;;     ## will force (re)install those deps.
;;     upgradeMassmine(mm_deps)
;;   }
;;   config_file = args[1]
;; }

;; Check for the user configuration file and parse it if available
;; config = mmConfig(config_file)

;; If MassMine was called interactively (from the command line, rather
;; than sourced from within an active R session), then it is
;; controlled by the user's configuration file
;; if (!interactivep) {
;;   ## The user's customization file determines which modules will be
;;   ## loaded.
;;   loadModules(config, mm_module_dir)

;;   ## Task dispatcher. We now call whatever tasks the user has requested.
;;   taskDispatch(config)

;;   ## All finished!
;;   cat('MassMine finished successfully!\n')
;; } else {
;;   ## Just load the requested modules, but do nothing else
;;   loadModules(config, mm_module_dir)

;;   ## Let the user know something happened. The rest is up to them.
;;   cat('\nMassMine is loaded and ready to go\n\n')
;; }

;;; Just what you think. This gets things started
(define (main)
  (if (not max-tweets)
      (set! max-tweets (string->number (alist-ref 'count options))))
  (if (not keywords)
      (set! keywords (alist-ref 'pattern options)))
  (if (not global-max-seconds)
      (set! global-max-seconds (string->number (alist-ref 'time options))))
  (if (not locations)
      (set! locations (alist-ref 'geo options)))

  ;; Greet the user
  (if (and do-splash? output-to-file?) (splash-screen))

  ;; Get things done
  (if output-to-file?
      (let ((out-file (alist-ref 'output options)))
	(if (file-exists? out-file)
	    ;; Abort if the output file already exists
	    (begin (with-output-to-port (current-error-port)
		     (lambda ()
		       (print "Abort: Output file " out-file
			      " already exists!")))
		   (exit 1))
	    ;; Else, get down to business
	    (begin
	      (display "Fetching requested data... ")
	      (with-output-to-file out-file
		(lambda () (fetch-data keywords locations language))))))
      (fetch-data keywords locations language))

  (if output-to-file? (print "done!"))
  
  (exit 1))

(define options)
(define operands)
(define do-splash? #t)
(define output-to-file? #f)
(define max-tweets 999999999999999999)
(define global-max-seconds 999999999999999999)
(define keywords "")
(define locations "")
(define language "")

;; Parse command line arguments
(set!-values (options operands)
	     (args:parse (command-line-arguments) opts))

;; (handle-exceptions exn (usage) (main))
(main)

;; End of file massmine