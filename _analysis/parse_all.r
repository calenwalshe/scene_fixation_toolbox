# Parse trial events
library(tidyr)

load('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_data.rdata')

all_events <- lapply(1:2, FUN = function(x) all_data[[x]]$combined.events %>% mutate(experiment = x)) %>% do.call(rbind, .)

all_events_nested <- all_events %>% group_by(trial, experiment) %>% nest()

# Parse the critical fixations
all.between <- purrr::map(all_events_nested$data, function(data) {
    onset.idx <- which(data$event.name %in% c("UP", "DOWN", "NOCHANGE"))
    
    critical.fix <- map(onset.idx, function(x) {
      saccade.end.idx <- which(data$event.name %in% c("saccadeStartNum"))
      onset.idx.pair  <- saccade.end.idx[first(which(saccade.end.idx > x))]
      
      data[x:onset.idx.pair,]
    })
  }
  )

# Label parsing
all_events_nested$critical_fixation <- all.between

all_events_nested$critical_fixation <- map(all_events_nested$critical_fixation, function(x) tibble(n_fix = 1:6, critical_events = x))
all_events_nested <- all_events_nested %>% unnest(critical_fixation)

all_events_nested$critical_fix_type <- unlist(map(all_events_nested$critical_events, function(x) first(x$event.name)))

# Fixation Duration
all_events_nested$fixation_duration <- unlist(map(all_events_nested$critical_events, function(x) last(x$timestamp) - first(x$timestamp)))

# Number of cancellations
all_events_nested$N_cancel <- unlist(map(all_events_nested$critical_events, function(x) {
  sum(x$event.name == "labileInterruptNum" & x$timestamp > first(x$timestamp))}))
  

# Order factor levels
all_events_nested$critical_fix_type <- factor(all_events_nested$critical_fix_type, levels = c("NOCHANGE", "UP", "DOWN"))

# timer positions at crtical fixation.
all_events_nested$timer.value.at.critical.onset <- (map(all_events_nested$critical_events, function(x) x[1,c("timer.p", "labile.p", "nonlabile.p", "motor.p", "saccade.p", "timer.on", "labile.on", "nonlabile.on", "motor.on", "saccade.on")]))
all_events_nested <- all_events_nested %>% unnest(timer.value.at.critical.onset)
all_events_nested <- all_events_nested %>% mutate(timer_bin = factor(cut(timer.p, seq(0, 1.001, .1001), labels = F, right = FALSE)), labile_bin = factor(cut(labile.p, seq(0, 1.001, .1001), labels = F, right = FALSE)))

all_events_nested[all_events_nested$timer.p == 1, c("timer.p", "labile.p")] <- 0 # set all timer at max to 0 labile

all_events_nested <- all_events_nested %>% group_by(experiment, critical_fix_type) %>% group_by(timer_bin, labile_bin) %>% mutate(labile_bin_time = mean(labile.p), timer_bin_time = mean(timer.p))