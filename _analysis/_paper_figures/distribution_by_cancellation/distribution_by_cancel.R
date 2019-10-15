rm(list = ls())

# Distribution by number of cancellations.
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_events_nested.rdata')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model.human.rdata')


###
# Comparison between human and model
theme_set(theme_clean())

binned.data <- all_events_nested %>%
  filter(fixation_duration < 2000) %>%
  group_by(experiment, experiment_group, condition) %>% 
  mutate(bin = cut(fixation_duration, breaks = seq(0, 2130, 60), labels = seq(30, 2100, 60))) %>% 
  group_by(experiment, experiment_group, condition, N_cancel, bin) %>%
  summarize(obs.count = n()) %>%
  group_by(experiment, experiment_group, condition) %>%
  mutate(obs.p = obs.count / sum(obs.count)) %>%
  rename(fixation_duration = bin)

binned.data$fixation_duration <- as.numeric(as.character(binned.data$fixation_duration))

binned.data <- binned.data %>% filter(fixation_duration < 1200) %>% filter(N_cancel < 4, experiment == "Full")

model.human.merge <- model.human %>% select(-model) %>% rename(fixation_duration = duration) %>% rename(obs.p = human)

fig.1 <- ggplot(binned.data %>% filter(), aes(x = fixation_duration, 
                                              y = obs.p, 
                                              fill = as.factor(N_cancel), 
                                              colour = as.factor(N_cancel))) + 
  geom_bar(stat = "identity") + 
  facet_grid(experiment_group ~ condition) + 
  geom_line(data = model.human.merge, aes(x = fixation_duration, y = obs.p), inherit.aes = F, colour = "red") +
  guides(colour = FALSE, fill = guide_legend(title = "Number of cancellations")) +
  scale_fill_viridis_d() +
  scale_colour_viridis_d() +
  xlab("Fixation Duration") +
  ylab("Proportion") +
  theme(aspect.ratio = 1) +
  scale_x_continuous(breaks = c(seq(0, 1000, 250))) +
  guides(colour = FALSE, fill = FALSE) +
  theme(axis.text = element_text(size = 6), strip.text = element_text(size = 7))

plot(fig.1)

ggsave(plot = fig.1, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/distribution_by_cancellation/cancel_distribution.pdf", width = 4, useDingbats = F)

