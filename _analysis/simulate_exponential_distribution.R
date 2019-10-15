total.sum <- 100

p.slow <- seq(.1,.5,.05)

matches <- lapply(p.slow, FUN = function(x) {
  p.fast <- 1 - x
  duration <- replicate(1000, {
    r.slow <- rexp(total.sum * p.slow, .5)
    r.fast <- rexp(total.sum * p.fast, 1)
    
    sum(r.slow, r.fast)})
}) %>% tibble(sample = .)
  
matches$p.slow <- p.slow

matches$mean.duration <- map(matches$sample, mean)

matches.1 <- matches %>% unnest(mean.duration)

plot(matches.1$p.slow, matches.1$mean.duration)

hist(duration)


     