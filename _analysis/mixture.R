library(mclust, quietly=TRUE)
library(purrrlyr)

raw.fixations <- get_raw_fixations()
raw.fix.nest <- raw.fixations %>%
  group_by(condition, experiment) %>% 
  nest()

mixture.fit <- raw.fix.nest %>%
  mutate(mixture = purrr::map(data, function(data) {
    
    fit = Mclust(data$duration, G=3, model="V")
    
  }))

testtt <- MclustBootstrap(mixture.fit$mixture[[1]])

mixture.mean <- purrr::map(mixture.fit$mixture, list("parameters", c("mean")))
mixture.sd   <- purrr::map(mixture.fit$mixture, list("parameters", "variance", "sigmasq"))

mixture.sd <- lapply(mixture.sd, sqrt)

mixture.fit$sd <- mixture.sd
mixture.fit$mean <- mixture.mean

mixture.fit <- 
  mixture.fit %>% 
  unnest(sd, mean, .drop = F) %>%
  group_by(condition, experiment) %>%
  mutate(N_cancel = 0:2) %>% 
  ungroup()

levels(mixture.fit$condition) <- c("NOCHANGE", "UP", "DOWN")

summary.stats.group <- all_events_nested %>% group_by(critical_fix_type, experiment, N_cancel) %>% summarize(mean.dur = mean(fixation_duration), sd.dur = sd(fixation_duration))
summary.stats.group <- summary.stats.group %>% rename(condition = critical_fix_type) %>% filter(N_cancel < 3)
summary.stats.group$N_cancel <- as.factor(summary.stats.group$N_cancel)
summary.stats.group$experiment <- as.factor(summary.stats.group$experiment)
summary.stats.group$condition <- as.factor(summary.stats.group$condition)

levels(summary.stats.group$condition) <- c("1", "2", "3")


mixture.fit$condition <- as.factor(mixture.fit$condition)
mixture.fit$experiment <- as.factor(mixture.fit$experiment)
mixture.fit$N_cancel <- as.factor(mixture.fit$N_cancel)

combined.stats <- left_join(mixture.fit, summary.stats.group, by = c("condition", "experiment", "N_cancel"))

combined.stats <- combined.stats %>% gather("measure", "value", mean, mean.dur, sd, sd.dur)

# How do the statistics for the clusters compare with the statistics for the cancellation distributions? 
ggplot(combined.stats, aes(x = N_cancel, y = value, colour = measure)) + geom_point() + facet_grid(condition ~ experiment)

# visualize it all together.
mixture.model <- mixture.fit %>% group_by(condition, experiment, N_cancel) %>% nest() %>%
  mutate(fixation_duration = map(data, function(x) {
    fixation_duration <- rnorm(100000, mean = x$mean, sd = x$sd)
  })) %>% 
  unnest(fixation_duration, .drop = T) %>%
  mutate(model_type = "mixture") %>%
  mutate(critical_fix_type = ifelse(condition == 1, "NOCHANGE", ifelse(condition == 2, "UP", "DOWN"))) %>%
  select(-condition)

random.walk.model <- all_events_nested %>% ungroup() %>% 
  select(experiment, critical_fix_type, fixation_duration, N_cancel) %>% 
  mutate(model_type = "random_walk") %>%
  filter(N_cancel < 10)

random.walk.model$experiment <- as.factor(random.walk.model$experiment)
random.walk.model$N_cancel <- as.factor(random.walk.model$N_cancel)
random.walk.model$model_type <- as.factor(random.walk.model$model_type)
random.walk.model$critical_fix_type <- factor(random.walk.model$critical_fix_type, levels = c("NOCHANGE", "DOWN", "UP"))
mixture.model$experiment <- as.factor(mixture.model$experiment)
mixture.model$N_cancel <- as.factor(mixture.model$N_cancel)
mixture.model$model_type <- as.factor(mixture.model$model_type)
mixture.model$critical_fix_type <- factor(mixture.model$critical_fix_type, levels = c("NOCHANGE", "DOWN", "UP"))


combined.models <- rbind(mixture.model, random.walk.model)
human.dat.compare <- human.dat %>% select(-trial) %>% rename(critical_fix_type = condition, model_type = d_type, fixation_duration = duration)
human.dat.compare <- human.dat.compare %>%   mutate(critical_fix_type = ifelse(critical_fix_type == 1, "NOCHANGE", ifelse(critical_fix_type == 2, "UP", "DOWN")))
human.dat.compare$critical_fix_type <- factor(human.dat.compare$critical_fix_type, levels = c("NOCHANGE", "DOWN", "UP"))
human.dat.compare$experiment <- as.factor(human.dat$experiment)
human.dat.compare$N_cancel <- as.factor(-1)

combined.models <- rbind(combined.models, human.dat.compare)

test <- combined.models %>% filter(critical_fix_type == "NOCHANGE", experiment == 2) %>% group_by(experiment, critical_fix_type) %>% 
  mutate(bins = cut(fixation_duration, breaks = seq(0, 1200, length.out = 60), labels = seq(0, 1140, length.out = 59))) %>%
  group_by(experiment, model_type, critical_fix_type, N_cancel, bins) %>% 
  mutate(n = n()) %>%
  arrange(experiment, critical_fix_type, N_cancel, bins) %>%
  group_by(experiment, model_type, critical_fix_type, N_cancel, bins) %>% 
  summarize(frequency = sum(as.numeric(n)), fd.mean = mean(fixation_duration)) %>%
  group_by(experiment, model_type, critical_fix_type) %>%
  mutate(density = frequency / sum(frequency)) %>%
  mutate(bins = round(as.numeric(as.character((bins)))))


ggplot(test %>% filter(model_type %in% c("mixture")), aes(x = bins, y = density, colour = N_cancel)) + geom_line() + facet_grid(experiment ~ critical_fix_type)


ggplot(test %>% filter(!model_type %in% c("human", "mixture")), aes(x = bins, y = density, fill = N_cancel:model_type)) + 
  geom_bar(stat = "identity") + facet_grid(experiment ~ critical_fix_type) +
geom_bar(data = test %>% filter(model_type == "human"), aes(x = bins, y = density, alpha = .1), fill = "gray", stat = "identity") + facet_grid(experiment ~ critical_fix_type)

  



