rm(list = ls())

library(ggplot2)
library(dplyr)
library(moments)
library(tidyr)

#source('~/Dropbox/Calen/Work/ucm/scene_fixation_model/r_manuscript/R/import_parameters.R')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_events_nested.rdata')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model.human.rdata')


all_events_nested.1 <- all_events_nested %>% mutate(experiment_group = ifelse(grepl("Experiment 1", experiment), "exp1", "exp2"))

###
# Comparison between human and model
theme_set(theme_bw())
model.human <- model.human %>% mutate(experiment_group = ifelse(experiment_group == "Experiment 1", "exp1", "exp2"))

model.human.gather <- model.human %>% gather(key = type, value = p, model, human)

distribution.fig <- ggplot(model.human.gather,
                           aes(
                             x = duration,
                             y = p,
                             colour = experiment,
                             linetype = type
                           )) +
  geom_point() +
  geom_line() +
  facet_grid(experiment ~ condition + experiment_group) +
  theme(aspect.ratio = 1)

ggsave(plot = distribution.fig, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/distributions.pdf")

plot(distribution.fig)

model.human.mean.binned <- model.human %>% 
  group_by(condition, experiment, experiment_group) %>%
  filter(!is.na(duration)) %>%
  mutate(human = duration * human, model = duration * model) %>%
  summarize(human = sum(human), model = sum(model)) %>%
  gather(d_type, duration, human, model)

mean.fig <- ggplot(model.human.mean.binned, aes(x = condition, y = duration, colour = d_type)) + geom_point() + facet_grid(experiment ~ experiment_group) + theme(aspect.ratio = 1)

ggsave(plot = mean.fig, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/mean.pdf")

plot(mean.fig)

##

## Scatter of fixation durations
all_events_nested.2 <- all_events_nested.1 %>% filter(experiment %in% c("visionresearch_exp1_exported.", "visionresearch_exp2_exported."))

all_events_nested.2 %>% group_by(experiment, critical_fix_type) %>% summarize(labile.on.prop = mean(labile.on))
all_events_nested.2 <- all_events_nested.2 %>% filter(N_cancel < 4)


ggplot(all_events_nested.2, aes(x = first_labile_duration, fixation_duration, colour = as.factor(N_cancel))) + geom_point() + facet_grid(experiment~critical_fix_type)

##



## Correlation ##
cor.fig <- model.human %>% 
  filter(experiment == "Full") %>% 
  group_by(condition, experiment) %>%
  mutate(human = cumsum(human), model = cumsum(model)) %>%
  ggplot(., aes(x = human, y = model, linetype = as.factor(experiment),colour = as.factor(condition))) + 
  geom_point() + facet_grid(experiment_group ~ experiment) +
  xlab("Pr(Human Fixation Duration < x)") +
  ylab("Pr(Model Fixation Duration < x)")
  

ggsave(plot = cor.fig, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/correlation.pdf")


# Distribution by number of cancellations.
dat.1 <- all_events_nested %>% filter(fixation_duration < quantile(fixation_duration, .99)) %>% filter(experiment %in% c("visionresearch_exp1_exported.", "visionresearch_exp2_exported."))

ggplot(dat.1 %>% filter(N_cancel == 0), aes(x = fixation_duration)) + 
  geom_histogram(aes(x = fixation_duration, y = ..count../sum(..count..), position = "stack",colour = as.factor(N_cancel), fill = as.factor(N_cancel)), alpha = .2) +
  geom_freqpoly(data = dat.1 %>% select(experiment, critical_fix_type, fixation_duration), aes(y = ..count../sum(..count..))) +
  facet_grid(experiment ~ critical_fix_type) + theme(aspect.ratio = 1)
#####

# Distribution with no cancellations. What do the timer manipulations do?
dat.2 <- all_events_nested %>% filter(fixation_duration < quantile(fixation_duration, .99)) %>% filter(N_cancel == 0)

ggplot(dat.2, aes(x = fixation_duration)) + 
  geom_histogram(aes(x = fixation_duration, y = ..count../sum(..count..), colour = as.factor(experiment), fill = as.factor(experiment), position = "stack"), alpha = .2) +
  geom_freqpoly(data = dat.2 %>% select(experiment, condition, fixation_duration), aes(y = ..count../sum(..count..), colour = as.factor(experiment))) +
  facet_grid(experiment~condition)


##

# Where are the timers when critical fixations begin? #
all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  summarize(timer_on.p = mean(timer.on), 
            labile_on.p = mean(labile.on), 
            nonlabile_on.p = mean(nonlabile.on),
            motor_on.p = mean(motor.on),
            saccade_on.p = mean(saccade.on))

# Plot distribution by timer start position
all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  filter(N_cancel < 3) %>%
  group_by(experiment, critical_fix_type, labile_bin, timer_bin, N_cancel) %>%
  summarize(count = n()) %>%
  ggplot(.,
       aes(x = timer_bin, y = labile_bin, fill = log(count))) + geom_tile() + facet_grid(experiment~critical_fix_type + N_cancel) + theme(aspect.ratio =1)

##

# Fixation duration by labile timer position
all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0) %>%
  group_by(experiment, critical_fix_type, labile_bin) %>%
  summarize(fix.dur.mean = mean(fixation_duration)) %>%
  ggplot(.,
         aes(x = labile_bin, y = fix.dur.mean, colour = critical_fix_type)) + 
  geom_point() +
  facet_grid(~experiment)
#

# Probability of cancellation by timer and labile position

glm.dat <- all_events_nested %>%
  ungroup() %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0) %>% select(N_cancel, condition, experiment_group, experiment, timer.p, labile.p, fixation_duration) %>%
  mutate(bCancel = ifelse(N_cancel > 0, 1, 0), timer.p.rank = cut(timer.p, 10, labels = F)) %>% filter(timer.p.rank == 6) %>% filter()

glm.plot.dat <- glm.dat %>% group_by(condition, experiment_group, experiment) %>% mutate(labile.p.rank = cut(labile.p, 10, labels = F)) %>%
  group_by(experiment_group, condition, experiment, labile.p.rank) %>% summarize(labile.p = mean(labile.p), p.cancel = mean(bCancel))

ggplot(glm.plot.dat, aes(x = labile.p, y = p.cancel, colour = condition)) + geom_point() + facet_grid(experiment_group ~ experiment)

glm.1 <- glm(bCancel ~ timer.p + , family = binomial(link = "logit"), data = glm.dat)

plot(glm.1)




all_events_nested %>%
  group_by(experiment, condition) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0) %>%
  group_by(experiment, condition, timer.p, labile.p) %>%
  filter(n() > 30) %>% 
  summarize(p_cancel = sum(N_cancel > 0)/n()) %>%
  ggplot(.,
         aes(x = timer.p, y = p_cancel, colour = condition, linetype = as.factor(experiment), shape = condition)) + 
  geom_point() +
  stat_smooth(method = "lm", se = FALSE) +
  facet_wrap(~labile.p) +
  theme(aspect.ratio = 1)
 #

# Probability of cancellation by timer position
all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0) %>%
  group_by(experiment, critical_fix_type, timer.p) %>%
  filter(n() > 30) %>% 
  summarize(p_cancel = sum(N_cancel > 0)/n()) %>%
  ggplot(.,
         aes(x = timer.p, y = p_cancel, colour = critical_fix_type, linetype = as.factor(experiment), shape = critical_fix_type)) + 
  geom_point() +
  stat_smooth(method = "lm", se = FALSE) +
  theme(aspect.ratio = 1)
##

# Fixation duration by timer and lablile start position
ff <- all_events_nested %>%
  group_by(experiment, condition) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0, first.labile.cancel == 0) %>%
  group_by(experiment, condition) %>%
  filter(n() > 30) %>% 
  ggplot(.,
         aes(x = timer_duration, y = first_labile_duration, colour = timer_bin, fill = timer_bin)) + stat_binhex(bins = 32) + facet_grid(experiment ~ condition)

#+ geom_tile(aes(fill = labile.duration)) + facet_grid(experiment~critical_fix_type)

plot(ff)
#####

# Fixation duration by timer and lablile start position
all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0) %>%
  group_by(experiment, critical_fix_type, timer_bin, labile_bin) %>%
  filter(n() > 30) %>% 
  summarize(fix.dur.mean = mean(fixation_duration)) %>%
  ggplot(.,
         aes(x = timer_bin, y = labile_bin)) + geom_tile(aes(fill = fix.dur.mean)) + facet_grid(experiment~critical_fix_type)
#####

# Cancellations by timer and labile start position
all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0) %>%
  group_by(experiment, critical_fix_type, timer_bin, labile_bin) %>%
  filter(n() > 30) %>% 
  summarize(N_cancel.p = sum(N_cancel > 1)/n()) %>%
  ggplot(.,
         aes(x = timer_bin, y = labile_bin)) + geom_tile(aes(fill = N_cancel.p)) + facet_grid(experiment~critical_fix_type)
#

# Are there more cancellations in the UP and DOWN relative to baseline? #
all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0) %>%
  group_by(experiment, critical_fix_type,N_cancel) %>%
  filter(n() > 30) %>% 
  summarize(cancel.avg = n()) %>%
  ggplot(., aes(x = N_cancel, cancel.avg, colour = critical_fix_type, fill = critical_fix_type)) + geom_bar(stat = "identity", position = "dodge") + facet_grid(~experiment)

all_events_nested %>% filter(N_cancel > 0) %>% group_by(experiment) %>% summarize(n.trial = n())

#

# How much does UP and DOWN extend fixation durations from baseline? #
up.down.shift <- all_events_nested %>%
  group_by(experiment, condition) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0, N_cancel == 0) %>%
  group_by(experiment, condition, timer.p, labile.p) %>%
  mutate(timer_bin = factor(cut(timer.p, seq(0, 1.001, length.out = 4), labels = F, right = FALSE)), labile_bin = factor(cut(labile.p, seq(0, 1.001, length.out = 4), labels = F, right = FALSE))) %>%
  group_by(experiment, condition, timer_bin, labile_bin) %>%
  mutate(cut_point = cut(fixation_duration,30)) %>%
  group_by(experiment, condition, timer_bin, labile_bin, cut_point) %>%
  summarize(fd_rank = mean(fixation_duration), density = n()) %>%
  group_by(experiment, condition, timer_bin, labile_bin) %>%
  mutate(density = density / max(density))

ggplot(up.down.shift, aes(x = as.factor(fd_rank), y = density, colour = condition)) + 
  geom_density(stat = "identity", position = position_dodge(width = 1)) + 
  facet_grid(labile_bin ~ timer_bin + experiment)



# Summary statistics for individual cancellation bumps.

dat.1 <- all_events_nested %>% filter(N_cancel < 5) %>% 
  group_by(experiment, critical_fix_type, N_cancel) %>% 
  summarize(f.mean = mean(fixation_duration), f.sd = sd(fixation_duration), f.sk = skewness(fixation_duration))

ggplot(dat.1, aes(x = f.mean, y = f.sd, colour = as.factor(N_cancel), shape = as.factor(critical_fix_type))) + geom_point() + facet_grid(~experiment)

dat.2 <- dat.1 %>% group_by(critical_fix_type, experiment) %>% mutate(experiment_group = ifelse(grepl("exp1", experiment), "exp1", "exp2"))

dat.3 <- dat.2 %>% group_by(experiment_group, critical_fix_type) %>% nest()

dat.3$cancel.dist <- lapply(dat.3$data, FUN = function(x) {
  xx <- x %>% select(experiment, N_cancel, f.mean) %>% spread(experiment, f.mean)
  
  xx[,3] <- (xx[,3] - xx[,2])
  xx[,4] <- (xx[,4] - xx[,2])
  
  yy <- x %>% select(experiment, N_cancel, f.sd) %>% spread(experiment, f.sd)
  
  yy[,3] <- (yy[,3] - yy[,2])
  yy[,4] <- (yy[,4]  - yy[,2])
  
  zz <- data.frame(N_cancel = xx[,1], mean_ratio_no_encoding = xx[,3], mean_ratio_no_surprise = xx[,4], sd_ratio_no_encoding = yy[,3], sd_ratio_no_surprise = yy[,4])
  
  names(zz) <- c("N_cancel", "mean_ratio_no_encoding", "mean_ratio_no_surprise", "sd_ratio_no_encoding", "sd_ratio_no_surprise")
  
  return(zz)
})


dat.4 <- dat.3 %>% select(-data) %>% unnest(cancel.dist)

dat.5 <- dat.4 %>% gather(simulation_type, statistic.val, 4:7)

ggplot(dat.5, aes(x = N_cancel, y = statistic.val, colour = simulation_type)) + geom_point() + facet_grid(critical_fix_type~experiment_group + simulation_type) + theme(aspect.ratio = 1)


# A figure with the strengh of manipulations

cancel_lobes <- all_events_nested %>% mutate(luminance_delta = ifelse(experiment == 1 & critical_fix_type == "NOCHANGE", 0, ifelse(
  experiment == 1 & critical_fix_type == "UP", 20,
  ifelse(
    experiment == 1 & critical_fix_type == "DOWN", -20,
    ifelse(experiment == 2 & critical_fix_type == "NOCHANGE", 0,
           ifelse(experiment == 2 & critical_fix_type == "DOWN", -40,
                  ifelse(experiment == 2 & critical_fix_type == "UP", 40, -1))))))) %>%
  filter(N_cancel < 3) 
  #mutate(luminance_delta = as.factor(luminance_delta))

cancel_lobes %>% group_by(luminance_delta, N_cancel) %>%
  mutate(bins = cut(fixation_duration, breaks = seq(0, 1200, 30), labels = seq(15, 1185, 30), right = F)) %>%
  group_by(luminance_delta, N_cancel, bins) %>%
  tally() %>%
  group_by(luminance_delta) %>%
  mutate(density = n / sum(n), bins = as.numeric(as.character(bins))) %>%
  ggplot(., aes(x = bins, y = density, fill = luminance_delta)) + 
  geom_bar(position = position_fill(), stat = "identity")

cancel_lobes %>% group_by(luminance_delta, N_cancel) %>%
  mutate(bins = cut(fixation_duration, breaks = seq(0, 1200, 30), labels = seq(15, 1185, 30), right = F)) %>%
  group_by(luminance_delta, N_cancel, bins) %>%
  tally() %>%
  group_by(luminance_delta) %>%
  mutate(density = n / sum(n), bins = as.numeric(as.character(bins))) %>%
  ggplot(., aes(x = bins, y = density, fill = luminance_delta)) + 
  geom_bar(position = position_fill(), stat = "identity") +
  facet_grid(~N_cancel) + 
  theme(aspect.ratio = 1)

# Visualize cancellation bumps compared.
cancel_lobes %>%
  group_by(N_cancel, luminance_delta) %>%
  summarize(mean.fd = mean(fixation_duration), std.fd = sd(fixation_duration)) %>%
  gather(type, val, mean.fd, std.fd) %>%
  ggplot(., aes(x= luminance_delta, y = val, colour = type, shape = factor(N_cancel))) + geom_point()
  


