
# function to evaluate returns from prices --------------------------------

eval.log.returns <- function(prices){
  past.prices <- prices[-length(prices)]
  prices <- prices[-1]
  returns <- 100*(log(prices)-log(past.prices))
  return(returns)
}

eval.returns <- function(prices){
  past.prices <- prices[-length(prices)]
  prices <- prices[-1]
  returns <- (prices - past.prices)/past.prices
  return(returns)
}

data <- read.csv("BTC-USD.csv")
prices <- data$Adj.Close
log.returns <- eval.log.returns(prices)
returns <- eval.returns(prices)

# fit distributions and plot ----------------------------------------------

fit_distros <- function(data, flag=TRUE){
  
  # fit distros using MLE
  if(flag){
    # Plot the histogram of the data and the fitted distribution
    hist(data, probability = TRUE, main = "Distribution of prices fitted using MLE",
         ylim=c(0, 18e-05), border="white",  xlim=c(0,60000))
    
    fit_lnorm <- fitdist(data, "lnorm")
    fit_weibull <- fitdist(data, "weibull")
  }
  else{
    # Plot the histogram of the data and the fitted distribution
    hist(data, probability = TRUE, main = "Distribution of returns fitted using MLE",
         ylim=c(0, 0.12), border="white", xlim=c(-30,20))
  }
  fit_norm <- fitdist(data, "norm")
  fit_cauchy <- fitdist(data, "cauchy")
  
  colo = viridis::viridis(4, .7)
  
  curve(dnorm(x, mean = fit_norm$estimate["mean"], sd = fit_norm$estimate["sd"]),
        col = colo[1], lwd = 2, add = TRUE)
  curve(dcauchy(x, location = fit_cauchy$estimate["location"], scale = fit_cauchy$estimate["scale"]),
        col = colo[4], lwd = 2, add = TRUE)
  if(flag){
    curve(dlnorm(x, mean = fit_lnorm$estimate["meanlog"], sd = fit_lnorm$estimate["sdlog"]),
          col = colo[2], lwd = 2, add = TRUE)
    curve(dweibull(x, shape = fit_weibull$estimate["shape"], scale = fit_weibull$estimate["scale"]),
          col = colo[3], lwd = 2, add = TRUE)
    legend("right", legend = c("Normal", "Log-normal", "Weibull", "Cauchy"), col = colo, lwd = 2)
  }
  else{
    legend("right", legend = c("Normal", "Cauchy"), col = c(colo[1], colo[4]), lwd = 2)
  }
  grid()
}

