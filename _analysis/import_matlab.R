import_scene_exp <- function() {
  library(dplyr)
  library(R.matlab)
  library(purrr)
  library(tidyr)
  library(parallel)
  
  map <- purrr::map
  # Import the fixation duration data
  
  all.files <- list.files("~/Dropbox/Calen/Work/ucm/scene_fixation_model/_export/", full.names = T) %>%
    .[grepl("exported", .)]
  
  data.list <- mclapply(all.files, FUN = function(x) {
    data <- readMat(x) 
    # Data from MATLAB
    trial.dat             <- data$export.data[1][[1]]
    step.dat              <- data$export.data[2]
    event.keys            <- data.frame((data$export.data[[4]]))
    event.keys$event.name <- row.names(event.keys)
    names(event.keys)     <- c("event", "event.name")
    
    # Format Data from trials store in dataframe
    trial.dat       <-
      lapply(
        1:length(trial.dat),
        FUN = function(x) {
          d.frame <-
            data.frame(trial.dat[[x]][[1]])
          
          if(ncol(d.frame) == 13) {
            names(d.frame) <- c("event", "timer.p", "labile.p", "nonlabile.p", "motor.p", "saccade.p",
                                "timer.on", "labile.on", "nonlabile.on", "motor.on", "saccade.on",
                                "timestamp", "trial")
          } else {
            names(d.frame) <- c("event", "duration", "timestamp", "trial")
            d.frame <- d.frame[, setdiff(names(d.frame), "timestamp")]
          }
          
          #d.frame <- d.frame %>% gather(key, value)
          return(d.frame)
        }
      )
    
    idx                   <- map(trial.dat, ncol)
    event.keys$event      <- as.numeric(event.keys$event)
    
    
    step.dat.dframe <- data.frame(step.dat) %>% as_tibble()
    names(step.dat.dframe) <- c("event", "timer.p", "labile.p", "nonlabile.p", "motor.p", "saccade.p",
                                "timer.on", "labile.on", "nonlabile.on", "motor.on", "saccade.on",
                                "timestamp", "trial")
    
    timer.data      <- trial.dat[idx == 13] %>% do.call(rbind, .)
    fix.dur.data    <- trial.dat[idx < 13] %>% do.call(rbind, .)
    
    all.timer <- rbind(step.dat.dframe, timer.data) %>% left_join(., event.keys, by = "event") %>% arrange(trial, timestamp)
    all.fixdur <- left_join(fix.dur.data, event.keys, by = "event")
    
    ## Human Data
    human.dat <- data.frame(data[1][[1]][[3]][[1]]) %>%
      as_tibble()
    
    names(human.dat) <- c("condition", "p", "duration")
    human.dat$condition <- as.factor(human.dat$condition)
    
    experiment.parse <- regmatches(x,regexpr("(?<=//)[[:alnum:]].+\\.", x, perl = TRUE))
    
    all.dat <- list(combined.events = all.timer, fixdur.events = all.fixdur, human.dat = human.dat, event.keys = event.keys, experiment = experiment.parse)    
    
  }, mc.cores = 6)

  return(data.list)
}
