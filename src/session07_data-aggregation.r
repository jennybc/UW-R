library(ggplot2)

##install.packages("plyr", dependencies = TRUE)
library(plyr)

gDat <- read.delim("../data/gapminderDataFiveYear.txt")
str(gDat)

## built-in apply() function operates on a MATRIX, not a data.frame
tDat <- with(gDat,
             cbind(cambodia = lifeExp[country == "Cambodia"],
                   canada = lifeExp[country == "Canada"],
                   rwanda = lifeExp[country == "Rwanda"]))
rownames(tDat) <- with(gDat, year[country == "Canada"])
str(tDat)
tDat

apply(tDat, 1, mean)
apply(tDat, 2, median)
rowMeans(tDat)
which.min(tDat[1, ])
apply(tDat, 1, which.min)
colnames(tDat)
colnames(tDat)[apply(tDat, 1, which.min)]
apply(tDat, 2, min)
apply(tDat, 2, summary)
apply(tDat, 2, quantile)
apply(tDat, 2, quantile, probs = c(0.05, 0.95))

## challenge:
## use apply to compute the range of lifeExp for each country
apply(tDat, 2, range)
apply(tDat, 2, function(x) c(min = min(x), max = max(x)))

## challenge:
## compute the interquartile range of lifeExp by country
## hint IQR()
apply(tDat, 2, IQR)
apply(tDat, 2, function(x) diff(quantile(x, probs = c(0.25, 0.75))))

## leaving matrices and apply()

## splitting up a vector based on a factor
aggregate(lifeExp ~ continent, gDat, FUN = mean)
str(aggregate(lifeExp ~ continent, gDat, FUN = mean))

aggregate(lifeExp ~ year * continent, gDat, FUN = mean)
leByYearAndContinent <- aggregate(lifeExp ~ year * continent, gDat, FUN = mean)
ggplot(leByYearAndContinent, aes(x = year, y = lifeExp, color = continent)) +
  geom_line() + geom_point()

aggregate(lifeExp ~ year * continent, gDat, quantile,
          probs = c(0.05, 0.95))

# how many countries pre continent?
aggregate(country ~ continent, gDat, function(x) length(unique(x)))

## challenge:
## compute the min and max of gdpPercap for each country
## ditto ... for 3 countries of your choice
aggregate(gdpPercap ~ country, gDat, quantile, probs = c(0, 1))
aggregate(gdpPercap ~ country, gDat, range)
aggregate(gdpPercap ~ country, gDat, function(x) c(min(x), max(x)))
aggregate(gdpPercap ~ country, gDat, range,
          subset = country %in% c("Turkey", "Sudan", "Japan"))

## leaving single vectors and factors and aggregate() ...

## ddply()
library(plyr)

ggplot(subset(gDat, country == "Zimbabwe"),
       aes(x = year, y = lifeExp)) +
  geom_point() + geom_smooth(se = FALSE, method = "lm")

lm(lifeExp ~ year, gDat, subset = country == "Zimbabwe")

(yearMin <- min(gDat$year))
lm(lifeExp ~ I(year - yearMin), gDat, subset = country == "Zimbabwe")

jFit <- lm(lifeExp ~ I(year - yearMin), gDat,
           subset = country == "Zimbabwe")
coef(jFit)

jFun <- function(z) {
  jFit <- lm(lifeExp ~ I(year - yearMin), z)
  jCoef <- coef(jFit)
  names(jCoef) <- c("intercept", "slope")
  return(jCoef)
}

jFun(subset(gDat, country == "Zimbabwe"))
jFun(subset(gDat, country == "Canada"))

gCoef <- ddply(gDat, ~ country, jFun)
str(gCoef)

gCoef <- ddply(gDat, ~ country + continent, jFun)
str(gCoef)
tail(gCoef)

ggplot(gCoef, aes(x = intercept, y = slope)) + geom_point()
ggplot(gCoef, aes(x = intercept, y = slope, color = continent)) +
  geom_point()
ggplot(gCoef, aes(x = continent, y = slope)) +
  geom_jitter(position = position_jitter(width = 0.1))
