# create exponential distribution. 
x <- seq(0, 1, .001)
y <- qexp(x, rate = 1)


xx <- data.frame(x = x, y = y)

theme_set(theme_few())

fig <- ggplot(data = xx, aes(x = x, y = y)) + geom_line() + theme(aspect.ratio = 1)

ggsave(filename = '~/Dropbox/Calen/Work/ucm/new_paper/main_design/exponential.pdf')
