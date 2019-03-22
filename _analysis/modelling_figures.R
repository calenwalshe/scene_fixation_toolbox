library(moments)

###
# Comparison between human and model
load('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model_human.rdata')
model.human.gather <- model.human %>% gather(key = type, value = p, model, human)
ggplot(model.human.gather,
       aes(
         x = duration,
         y = p,
         colour = condition,
         linetype = type
       )) +
  geom_point() +
  geom_line() +
  facet_grid(experiment ~ condition)

model.human.mean.binned <- model.human %>% 
  group_by(condition, experiment) %>%
  filter(!is.na(duration)) %>%
  mutate(human = duration * human, model = duration * model) %>%
  summarize(human = sum(human), model = sum(model)) %>%
  gather(d_type, duration, human, model)

ggplot(model.human.mean.binned, aes(x = condition, y = duration, colour = d_type)) + geom_point() + facet_grid(~experiment)
##

# Distribution by number of cancellations.
ggplot(all_events_nested, aes(x = fixation_duration)) + 
  geom_histogram(aes(x = fixation_duration, y = ..count../sum(..count..), position = "dodge",colour = as.factor(N_cancel), fill = as.factor(N_cancel)), alpha = .2) +
  geom_freqpoly(data = all_events_nested %>% select(experiment, critical_fix_type, fixation_duration), aes(y = ..count../sum(..count..))) +
  facet_grid(critical_fix_type~experiment)
#####

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

# Probability of cancellation by timer position
all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0) %>%
  group_by(experiment, critical_fix_type, timer.p, labile.p) %>%
  filter(n() > 30) %>% 
  summarize(p_cancel = sum(N_cancel > 0)/n()) %>%
  ggplot(.,
         aes(x = timer.p, y = p_cancel, colour = critical_fix_type)) + 
  geom_point() +
  facet_wrap(labile.p~experiment) +
  theme(aspect.ratio = 1)
 #

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
#

# How much does UP and DOWN extend fixation durations from baseline? #
up.down.shift <- all_events_nested %>%
  group_by(experiment, critical_fix_type) %>%
  filter(labile.on == 1, nonlabile.on == 0, motor.on == 0, saccade.on == 0, N_cancel == 0) %>%
  group_by(experiment, critical_fix_type, timer.p, labile.p) %>%
  mutate(timer_bin = factor(cut(timer.p, seq(0, 1.001, length.out = 4), labels = F, right = FALSE)), labile_bin = factor(cut(labile.p, seq(0, 1.001, length.out = 4), labels = F, right = FALSE))) %>%
  group_by(experiment, critical_fix_type, timer_bin, labile_bin) %>%
  mutate(cut_point = cut(fixation_duration,30)) %>%
  group_by(experiment, critical_fix_type, timer_bin, labile_bin, cut_point) %>%
  summarize(fd_rank = mean(fixation_duration), density = n()) %>%
  group_by(experiment, critical_fix_type, timer_bin, labile_bin) %>%
  mutate(density = density / max(density))

ggplot(up.down.shift, aes(x = as.factor(fd_rank), y = density, colour = critical_fix_type)) + geom_(width = 0, stat = "identity", position = position_dodge(width = 1)) + facet_grid(labile_bin ~ timer_bin + experiment)

# Summary statistics for individual cancellation bumps.

all_events_nested %>% filter(N_cancel < 5) %>% 
  group_by(experiment, critical_fix_type, N_cancel) %>% 
  summarize(f.mean = mean(fixation_duration), f.sd = sd(fixation_duration), f.sk = skewness(fixation_duration)) %>%
  ggplot(., aes(x = f.mean, y = f.sd, colour = as.factor(N_cancel), shape = as.factor(critical_fix_type))) + geom_point() + facet_grid(~experiment)

# Visualize cancellation bumps compared.
all_events_nested %>% filter(N_cancel < 5) %>% 
  group_by(experiment, critical_fix_type, N_cancel) %>% 
  ggplot(., aes(x = fixation_duration)) + 
  geom_histogram(aes(x = fixation_duration, y = ..count../sum(..count..), type = (as.factor(N_cancel)), position = "stack",colour = as.factor(critical_fix_type), fill = as.factor(critical_fix_type)), alpha = .2) + 
  facet_grid(~N_cancel) +
  theme(aspect.ratio = 1)

