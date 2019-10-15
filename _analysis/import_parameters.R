# Import model parameters from MATLAB

library(R.matlab)
library(knitr)
library(kableExtra)
library(xtable)

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

setup.table <- parameters %>% select(-Type) %>% spread(parameters, value)

setup.table[1,2:length(setup.table)]


setup.table <- cbind(t(setup.table[1,2:length(setup.table)]),t(setup.table[2,2:length(setup.table)]))

setup.table <- data.frame(setup.table[!grepl("N_labile|N_motor|N_nonlabile|N_saccade", row.names(setup.table)),])

names(setup.table) <- c("Experiment 1", "Experiment 2")

row.names(setup.table)[row.names(setup.table) == "timer1"] <- "N_states"

print(xtable(setup.table, type = "latex"), file = "~/Dropbox/Apps/Overleaf/Draft for scene fixation duration model/_tables/baseline_table.tex")

setup.table <- setup.table[c(11, 4, 6, 5, 7,12,10,8,3,1,9,2),]

kable(setup.table, row.names = F) %>% kable_styling(bootstrap_options = c("striped", "hover")) %>% save_kable(file = "~/Dropbox/Calen/Dropbox/parameter_table.html")

