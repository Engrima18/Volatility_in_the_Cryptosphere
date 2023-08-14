
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

# update the data set
data <- read.csv("BTC-USD.csv")
prices <- data$Adj.Close
data$LogReturns <- c(NA, eval.log.returns(prices))
data$Returns <- c(NA, eval.returns(prices))
data$Date <- as.Date(data$Date)

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


# plot decomposition of timeseries ------------------------------------

decomp.plot <- function(x, title = NULL, col="black")
{
  if(is.null(title)){
    main <- paste("Decomposition of", title, "time series")
  }
  else{
    main <- paste("Decomposition of", title, "time series")
  }
  plot(cbind(observed =x$x, trend = x$trend, seasonal = x$seasonal,
             random = x$random), main = main, col=col)
}


# plot the acf ------------------------------------------------------------

acf.plot <- function(ret){
  # Plot ACF for Returns
  returns_acf <- acf(ret[-1], plot = FALSE)
  returns_acf_df <- data.frame(lag = returns_acf$lag, acf = returns_acf$acf)
  
  significance_level <- qnorm((1 + 0.95)/2)/sqrt(sum(!is.na(data$LogReturns[-1])))
  
  plot1 <- ggplot(returns_acf_df, aes(x = lag, y = acf)) +
    geom_errorbar(mapping=aes(ymax=acf, ymin=0), stat = "identity", color = "darkblue", width = 0.5) +
    geom_hline(yintercept = 0, color = "gray30") +
    geom_hline(yintercept = c(-significance_level, significance_level),
               linetype = "dashed", color = "red") +
    labs(title = "ACF for Returns", x = "Lag", y = "ACF")
  
  # Plot ACF for Absolute Returns
  abs_returns_acf <- acf(abs(ret[-1]), plot = FALSE)
  abs_returns_acf_df <- data.frame(lag = abs_returns_acf$lag, acf = abs_returns_acf$acf)
  
  plot2 <- ggplot(abs_returns_acf_df, aes(x = lag, y = acf)) +
    geom_errorbar(mapping=aes(ymax=acf, ymin=0), stat = "identity", color = "darkblue", width = 0.5) +
    geom_hline(yintercept = c(-significance_level, significance_level),
               linetype = "dashed", color = "red") +
    geom_hline(yintercept = 0, color = "gray30") +
    labs(title = "ACF for Absolute Returns", x = "Lag", y = "ACF")
  
  print(plot1)
  print(plot2)
}
