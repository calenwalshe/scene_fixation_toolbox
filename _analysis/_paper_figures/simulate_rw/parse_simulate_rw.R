library(dplyr)
library(tidyr)

random.walks <- read.table('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/simulate_rw/exp.txt',
                           header = F)

names(random.walks) <- c("level_timer", "level_labile", "level_nonlabile", "level_motor", "level_saccade", "rate_timer", "rate_labile",
                         "rate_nonlabile", "rate_motor", "rate_saccade",
                         "t", "trial")

random.walks        <- as_tibble(random.walks)

random.walks.nest <- random.walks %>% group_by(trial) %>% nest()

# Prototype parser
all.parsed <- map(random.walks.nest$data, function(dat) {
  # Get all labile index
  max.labile <- max(dat$level_labile)
  
  labile.idx <- dat$level_labile
  
  labile.on.idx <- which(labile.idx == 1)
  
  diff.idx <- which(diff(labile.on.idx) > 1) + 1
  
  labile.on.idx.unique <- c(labile.on.idx[1], labile.on.idx[diff.idx])
  
  # For each labile index
  
  parsed.labile <- lapply(labile.on.idx.unique, function(x) {
    single.labile.idx <- x

    the.rest <- labile.idx[single.labile.idx:length(labile.idx)]
    
    diff.rest <- diff(the.rest)
    
    the.end    <- which(diff.rest == -16)[1]
    the.cancel <- which(diff.rest != -16 & diff.rest < 0)[1]
    
    if(is.na(the.end) | is.na(the.cancel)){
      
    }else if(the.end < the.cancel) {
      time.steps <- dat$t[single.labile.idx:(single.labile.idx + the.end - 1)]
      
      time.steps <- time.steps - min(time.steps)
      
      data.frame(labile.step = labile.idx[single.labile.idx:(single.labile.idx + the.end - 1)],
                 time.steps = time.steps,
                 cancel = 0,
                 labile.rate = dat$rate_labile[single.labile.idx:(single.labile.idx + the.end - 1)], labile.idx = x) 
    } else {
      time.steps <- dat$t[single.labile.idx:(single.labile.idx + the.cancel - 1)]
      
      time.steps <- time.steps - min(time.steps)
      
      data.frame(labile.step = labile.idx[single.labile.idx:(single.labile.idx + the.cancel - 1)],
                 time.steps = time.steps, 
                 cancel = 1,
                 labile.rate = dat$rate_labile[single.labile.idx:(single.labile.idx + the.cancel - 1)], labile.idx = x)
    }
  })
  
  parsed.labile.combined <- do.call(rbind, parsed.labile)
  return(parsed.labile.combined)
})

random.walks.nest$parsed <- all.parsed

random.walks.parsed <- random.walks.nest %>% select(-data) %>% unnest(parsed)

random.walks.parsed.1 <- random.walks.parsed %>% 
  mutate(unique.idx = interaction(trial, labile.idx)) %>% 
  mutate(labile.rate = round(labile.rate,2)) %>% 
  mutate(labile.step = labile.step / max(labile.step)) %>%
  group_by(cancel, labile.rate, unique.idx) %>% nest()

b.valid <- map(random.walks.parsed.1$data, function(x) {
  if(x$time.steps[1] != 0){
    return(0)
  } else if(max(x$labile.step) == 1) {
    return(1)
  } else {
    return(2)
  }})

random.walks.parsed.1$bValid <- unlist(b.valid)


random.walks.parsed.2 <- random.walks.parsed.1 %>% unnest(data) 
#%>% 
#  filter(bValid != 0 & ((bValid == 1 & cancel == 0) | (bValid == 2 & cancel == 1)))

random.walks.parsed.3 <- random.walks.parsed.2 %>%
  group_by(unique.idx) %>% 
  mutate(mean.labile.rate = mean(labile.rate)) %>%
  ungroup() %>%
  mutate(mean.labile.rate.group = cut(mean.labile.rate, c(.04, .05, .06, .07, .08), labels = F)) %>%
  group_by(cancel, mean.labile.rate.group, unique.idx) %>%
  nest() %>%
  group_by(cancel, mean.labile.rate.group) %>%
  sample_n(100) %>%
  unnest() %>%
  ungroup() %>%
  mutate(cancel = ifelse(cancel == 0, "No cancellation", "Cancellation")) %>%
  mutate(arrow_len = ifelse(cancel == 0, 0, 1))
  

random.walks.parsed.3$mean.labile.rate.group <- factor(random.walks.parsed.3$mean.labile.rate.group, levels = sort(c(1,2,3,4), decreasing = T), labels = sort(round(c(.045, .055, .065, .075)/.075 * 100), decreasing = T))

random.walks.parsed.3 <- random.walks.parsed.3 %>% 
  group_by(cancel, mean.labile.rate.group, unique.idx) %>% 
  mutate(max.time = (max(time.steps))) %>% 
  group_by(cancel, mean.labile.rate.group) %>% 
  mutate(mean.time = median(max.time))


palettes <- ggthemes_data[["tableau"]][["color-palettes"]][["regular"]]
tableau.10 <- palettes$`Tableau 10`

theme_set(theme_clean())
fig.1 <- ggplot(random.walks.parsed.3, aes(x = time.steps, y = labile.step, group = unique.idx, colour = as.factor(mean.labile.rate.group))) + 
  geom_step(alpha = .25, size = .5) +
  geom_vline(aes(xintercept = mean.time, colour = as.factor(mean.labile.rate.group)), linetype = "dashed") +
  facet_grid(~cancel) +
  theme(aspect.ratio = 1) +
  xlab("Time from labile onset") +
  ylab("Proportion of total labile completed") +
  #guides(colour = guide_legend(title = "Labile Timer Adjustment", override.aes = list(alpha = 1)))
  guides(colour = FALSE) +
  scale_colour_manual(values = tableau.10$value[1:4]) +
  facet_grid(mean.labile.rate.group~cancel)

plot(fig.1)

ggsave(filename = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/simulate_rw/_figures/random_walk.pdf', plot = fig.1, width = 4, units = "in")
       