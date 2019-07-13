# Import model parameters from MATLAB

library(R.matlab)

exp1 <- readMat('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_export/settings_exp1.mat')
exp2 <- readMat('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_export/settings_exp2.mat')

exp.both <- list(exp1, exp2)

parameters <- lapply(exp.both, FUN = function(x) {
  
  x <- x[[1]]
  
  rowVals <- rownames(x)
  
  n.trials <- as.numeric(x[rowVals == "NumberTrials"][[1]])
  
  number.states <- as.numeric(x[rowVals == "NumberStates"][[1]])
  walkrate     <- as.numeric(x[rowVals == "WalkRate"][[1]])
  model.params <- as.numeric(x[rowVals == "ModelParams"][[1]])
  experiment.name <- as.character(x[rowVals == "ExperimentName"][[1]])
  
  names(walkrate) <- c("timer", "labile", "nonlabile", "motor", "saccade")
  names(model.params) <- c("up_surprise", "up_encoding", "down_surprise", "down_encoding", "surprise_offset", "encoding_offset")
  names(number.states) <- c("timer", "labile", "nonlabile", "motor", "saccade")
  
  dat.1 <- data.frame(value = walkrate)
  dat.2 <- data.frame(value = model.params)
  dat.3 <- data.frame(value = number.states)
  
  dat.4 <- do.call(rbind, list(dat.1, dat.2, dat.3))
  
  dat.4$experiment <- experiment.name
  
  dat.4$parameters <- rownames(dat.4)
  
  return(dat.4)
})

parameters <- do.call(rbind, parameters)

parameters$Type <- ""
parameters[parameters$parameters %in% c("timer", "labile", "nonlabile", "motor", "saccade"), ]$Type <- "Timer"
parameters[parameters$parameters %in% c("timer1", "labile1", "nonlabile1", "motor1", "saccade1"), ]$Type <- "Total Steps"
parameters[parameters$parameters %in% c("up_surprise", "up_encoding", "down_surprise", "down_encoding"), ]$Type <- "Rate Adjustment"
parameters[parameters$parameters %in% c("surprise_offset", "encoding_offset"), ]$Type <- "Adjustment Offset"

parameters[parameters$parameters == "labile1",]$parameters    <- "N_labile"
parameters[parameters$parameters == "nonlabile1",]$parameters <- "N_nonlabile"
parameters[parameters$parameters == "motor1",]$parameters    <- "N_motor"
parameters[parameters$parameters == "saccade1",]$parameters  <- "N_saccade"

parameters[parameters$parameters == "down_surprise",]$parameters  <- "Surprise (Down)"
parameters[parameters$parameters == "up_surprise",]$parameters  <- "Surprise (UP)"

parameters[parameters$parameters == "down_encoding",]$parameters  <- "Encoding (Down)"
parameters[parameters$parameters == "up_encoding",]$parameters  <- "Encoding (UP)"

kable(parameters, row.names = F) %>% kable_styling(bootstrap_options = c("striped", "hover")) %>% save_kable(file = "~/Dropbox/Calen/Dropbox/parameter_table.html")

