# Import data
raw.data <- get_raw_data()

## Parse Trial Events ###

model <- raw.data

experiment.dat <- model %>%
  group_by(experiment) %>%
  nest()


all.between <- lapply(experiment.dat$data, FUN = function(data) {
  trial.dat <- data %>%
    group_by(trial) %>%
    nest()
  
  all.between <- purrr::map(trial.dat$data, function(data) {
    onset.idx <- which(data$event.name %in% c("UP", "DOWN", "NOCHANGE"))
    
    critical.fix <- map(onset.idx, function(x) {
      saccade.end.idx <- which(data$event.name %in% c("saccadeStartNum"))
      onset.idx.pair  <- saccade.end.idx[first(which(saccade.end.idx > x))]
      
      data[x:onset.idx.pair,]
    })
  }
  )
  
  trial.dat$data <- all.between
  
  return(trial.dat)
})

# Recombine parsed trial data
experiment.dat$data <- all.between
experiment.dat      <- experiment.dat %>% unnest(data) %>% unnest(data)
