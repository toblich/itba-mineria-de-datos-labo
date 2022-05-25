rm(list = ls())
gc()

require(ggplot2)
require(grid)

tiros <- 70

x  <- 0:tiros
p1 <- 0.7
p2 <- 0.6
df1 <- data.frame(x = x, y = pbinom(x, tiros, p1))
df2 <- data.frame(x = x, y = pbinom(x, tiros, p2))

plot1 <- ggplot(df1, aes(x = x, y = y)) +
  geom_line(stat = "identity", col = "red") +
  geom_line(data = df2, stat = "identity", col = "blue") +
  scale_y_continuous(expand = c(0.01, 0)) + xlab("x") + ylab("Density") +
  labs(title = sprintf("%i tiros", tiros)) + theme_bw(16, "serif") +
  theme(plot.title = element_text(size = rel(1.2), vjust = 1.5))

print(plot1)
