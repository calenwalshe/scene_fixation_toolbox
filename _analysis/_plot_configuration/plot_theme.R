# theme script for figures.

colours.1 <- c("#314455", "#644E5B", "#9E5A63", "#C96567", "#97AABD")
colours.2 <- c("#19181A", "#479761", "#CEBC81", "#A16E83", "#B19F9E")
colours.targets <- c("#F8E9A1", "#F76C6C", "#A8D0E6", "#374785", "#24305E")
colour.vals     <- c("#5D001E", "#E3AFBC", "#EE4C7C", "#31708E", "#5085A5", "#8FC1E3")

colour.regression <- #2D283E

ln.sz <- 2
point.sz <- 5.5
panel.border.sz = 4
tick.sz = 1
tick.length = .2
#axis.text.shift.x <- c(abs(tick.length) + .5,0,0,0)
#axis.text.shift.y <- c(0,abs(tick.length) + .5,0,0)

theme.1 <- theme_set(theme_minimal(base_size = 10)) +# pre-set the bw theme.
  theme(aspect.ratio = 1, 
                       axis.ticks = element_line(size = tick.sz),
                       axis.ticks.length=unit(tick.length, "cm"),
                       #axis.text.x = element_text(margin=unit(axis.text.shift.x, "cm")), 
                       #axis.text.y = element_text(margin=unit(axis.text.shift.y, "cm")),
                       panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                       legend.title=element_blank(),
                       legend.text = element_text(size = 25),
                       legend.key.size = unit(1, "cm"),
                       panel.border = element_rect(fill=NA, colour = "#19181A", size=panel.border.sz),
                       plot.title = element_text(hjust = 0.5))
