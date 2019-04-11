get_raw_data <- function() {
  exp.dat <- mclapply(1:2, FUN = function(x) import_scene_exp(x), mc.cores = 2)
  
  f <- function(x) {
    model.all         <- x$combined.events
    
    model.duration    <- model.all %>%
      select(-event) %>%
      mutate(d_type = "model") %>%
      as_tibble()
    
    model.duration <- unique(model.duration)
    
    return(model.duration)
  }
  
  model.dat <- lapply(1:length(exp.dat), FUN = function(x) { 
    f(exp.dat[[x]]) %>% 
      mutate(experiment = x)})
  
  model.dat <- do.call(rbind, model.dat) %>% arrange(experiment, trial, timestamp)
}

get_binned_fixations <- function() {
  library(ggplot2)
  library(tidyr)
  library(dplyr)
  library(stringr)
  library(purrr)
  source('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/import_matlab.R')
  
  exp.dat <- mclapply(1:2, FUN = function(x) import_scene_exp(x), mc.cores = 2)
  
  f <- function(x) {
    human.dat         <- x$human.dat %>%
      mutate(group = "human", duration = as.numeric(duration))
    
    model.all         <- x$fixdur.events
    names(model.all)  <- c("event", "duration", "trial", "condition")
    model.duration    <- model.all %>%
      filter(condition %in% c("DOWN.DUR", "UP.DUR", "NOCHANGE.DUR")) %>%
      select(-event) %>%
      mutate(d_type = "model") %>%
      as_tibble()
    
    model.duration$condition <-
      factor(
        model.duration$condition,
        levels = c("NOCHANGE.DUR", "UP.DUR", "DOWN.DUR"),
        labels = c(1, 2, 3)
      )
    
    breaks        <- c(0, unique(human.dat$duration))
    
    model.binned  <- model.duration %>%
      group_by(condition) %>%
      filter(duration < 2000) %>%
      summarize(bin = list(hist(
        duration,
        breaks = seq(0, 2000, 30),
        right = F,
        plot = T
      )))
    
    model.binned <-
      map2(model.binned$bin, model.binned$condition, function(x, y) {
        condition <- x$condition
        p         <- x$count / sum(x$count)
        duration  <- x$mids
        condition <- y
        data.frame(condition = condition,
                   p = p,
                   duration = duration)
      }) %>%
      do.call(rbind, .) %>%
      filter(duration < 1200) %>%
      mutate(group = "model") %>%
      filter(!is.na(duration))
    
    duration.data <- rbind(model.binned, human.dat) %>%
      as_tibble()
    
    model.human <-
      rbind(human.dat, model.binned) %>% spread(p, key = group)
  }

  dur.exp.dat <- lapply(1:length(exp.dat), FUN = function(x) f(exp.dat[[x]]) %>% mutate(experiment = x))
  
  do.call(rbind, dur.exp.dat)
}

# Human raw fixation data.
get_raw_fixations <- function() {
  human.dat <- read.csv('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/human_raw_data.csv', header = T) %>% mutate(d_type = "human") %>% unique()
}
