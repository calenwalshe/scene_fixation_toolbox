load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_events_nested.rdata')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model.human.rdata')

# format data
all_events_nested.1 <- all_events_nested %>% mutate(experiment_group = ifelse(grepl("Experiment 1", experiment_group), "exp1", "exp2"))

# select data
## Scatter of fixation durations
all_events_nested.2 <- all_events_nested %>% filter(experiment == "Full")

# more selection and formatting
all_events_nested.2 %>% group_by(experiment, condition, experiment_group) %>% summarize(labile.on.prop = mean(labile.on)) 
all_events_nested.2 <- all_events_nested.2 %>% filter(N_cancel == 0, labile.on == 1) %>% 
  group_by(experiment_group, condition, N_cancel) %>% 
  filter(!is.na(fixation_duration) & !is.na(first_labile_duration))

all_events_nested.3 <- all_events_nested.2 %>% filter(N_cancel == 0) %>% 
  mutate(labile.p.group = cut(labile.p, breaks = seq(0, 1, length.out= 4), include.lowest = T, labels = round(seq(.33/2, 1, length.out= 4)[1:3],2)))
  
all_events_nested.3$labile.p.group.mean <- factor(all_events_nested.3$labile.p.group, 
                                             levels = unique(all_events_nested.3$labile.p.group))

library(viridisLite)

theme_set(theme_clean(base_size=15))
fig.1 <- ggplot(all_events_nested.3, aes(colour = as.factor(labile.p.group.mean), fill = as.factor(labile.p.group.mean))) + 
  stat_density_2d(data = all_events_nested.3 %>% 
                             filter(labile.p.group == sort(unique(labile.p.group)[1])), 
                           aes(x = first_labile_duration, y = fixation_duration), size = .75, linetype = 1) +
  geom_point(data = all_events_nested.3 %>% 
                    filter(labile.p.group == sort(unique(labile.p.group)[1])) %>% sample_frac(.009), 
                  aes(x = first_labile_duration, y = fixation_duration), alpha = .5) +
  stat_density_2d(data = all_events_nested.3 %>% 
                    filter(labile.p.group == sort(unique(labile.p.group)[2])), 
                  aes(x = first_labile_duration, y = fixation_duration), size = .75, linetype = 1) +
  geom_point(data = all_events_nested.3 %>% 
               filter(labile.p.group == sort(unique(labile.p.group)[2])) %>% sample_frac(.009), 
             aes(x = first_labile_duration, y = fixation_duration), alpha = .5) +
  stat_density_2d(data = all_events_nested.3 %>% 
                    filter(labile.p.group == sort(unique(labile.p.group)[3])), 
                  aes(x = first_labile_duration, y = fixation_duration), size = .75, linetype = 1) +
  geom_point(data = all_events_nested.3 %>% 
               filter(labile.p.group == sort(unique(labile.p.group)[3])) %>% sample_frac(.012), 
             aes(x = first_labile_duration, y = fixation_duration), alpha = .5) +
  scale_color_tableau(palette = "Tableau 10", type = c("regular",
                                                       "ordered-sequential", "ordered-diverging"), direction = 1) +
  coord_cartesian(xlim = c(0, 300), ylim = c(0, 450)) +
  xlab("Labile Duration") +
  ylab("Fixation Duration") +
  guides(fill = FALSE, colour = guide_legend(title = "Labile Completed")) +
  theme(aspect.ratio = 1)

plot(fig.1)

ggsave(plot = fig.1, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/pre_programming/_figures/pre_programming.pdf", width = 7, height = 3.5, useDingbats = FALSE)
