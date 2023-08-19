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


# trace plots -------------------------------------------------------------

tg <- ggs(as.mcmc(tstud_garch_model)) # convert to ggs object
trace1 <- ggs_traceplot(tg, family = "mu")
trace2 <- ggs_traceplot(tg, family = "omega")
trace3 <- ggs_traceplot(tg, family = "alpha")
trace4 <- ggs_traceplot(tg, family = "beta")


# Volatility forecasting --------------------------------------------------

volatility.plot <- function(model1, model2, y){
  a <- model1$BUGSoutput$mean$alpha
  b <- model1$BUGSoutput$mean$beta
  m <- model1$BUGSoutput$mean$mu
  o <- model1$BUGSoutput$mean$omega
  N <- length(y)
  
  y <- y[-1]
  sigmas <- rep(1,N)
  for (t in 2:N) {
    sigmas[t] <- sqrt(o + a * (y[t - 1] - m)^2 + b * sigmas[t - 1]^2)
  }
  
  
  an <- model2$BUGSoutput$mean$alpha
  bn <- model2$BUGSoutput$mean$beta
  mn <- model2$BUGSoutput$mean$mu
  on <- model2$BUGSoutput$mean$omega
  
  sigmas_n <- rep(1,N)
  for (t in 2:N) {
    sigmas_n[t] <- sqrt(on + an * (y[t - 1] - mn)^2 + bn * sigmas_n[t - 1]^2)
  }
  
  par(mfrow=c(2,1), mar=c(1, 4, 3, 4))
  par(main = "Volatility Forecasting")
  
  plot(y, type = 'l', col = 'violet', lwd = 2, ylab = '',
       xlab = '', xaxt = 'n', yaxt = 'n', main = "Volatility Forecasting")
  lines(sigmas, type = 'l', col = 'darkviolet', lwd = 2)
  mtext("Student t GARCH", side = 2, line = 2)
  grid()
  
  plot(y, type = 'l', col = 'violet', lwd = 2, ylab = '',
       xlab = '', xaxt = 'n', yaxt = 'n')
  lines(sigmas_n, type = 'l', col = 'darkviolet', lwd = 2)
  mtext("Gaussian GARCH", side = 2, line = 2)
  grid()
}


# MSE ---------------------------------------------------------------------

mse <- function(true, pred){
  return(mean((true-pred)^2))
}


# NA-forecasting ----------------------------------------------------------

na.forecast <- function(model, data, n){
  # Initialize a matrix to store the last n 'y' values
  preds <- rep(NA, n)
  
  # Loop through the last 30 iterations and extract 'y'
  total_iterations <- length(model$BUGSoutput$sims.list$y)
  for (i in 1:n) {
    preds[i] <- model$BUGSoutput$sims.list$y[[total_iterations - n + i]]
  }
  
  data$LogReturns <- c(NA, eval.log.returns(data$Adj.Close))
  
  N1 <- length(data$LogReturns)
  true_ret <- head(tail(data$LogReturns, 30),20)
  dates <- as.Date(head(tail(data$Date, 30),20))
  
  df <- data.frame(pred=preds, true=true_ret, Date=dates)
  return(df)
}

# marginal likelihood comparison -----------------------------------------

# Function to calculate log posterior for ARCH model
# log_posterior_ARCH <- function(samples.row, data) {
#   mu <- samples.row[, "mu"]
#   omega <- samples.row[, "omega" ]
#   alpha <- samples.row[,"alpha"]
#   sigma <- sqrt(omega + alpha * (data$y[-1] - mu)^2)
#   
#   res <- sum(dnorm(data$y, mu, sigma, log = TRUE)) +
#     dunif(omega, 0, 10, log = TRUE) +
#     dunif(alpha, 0, 1, log = TRUE) +
#     dnorm(mu, 0.0, 0.01, log = TRUE)
#   return(res)
# }
# 
# # Function to calculate log posterior for GARCH model
# log_posterior_GARCH <- function(samples.row, data) {
#   mu <- samples.row[, "mu" ]
#   sigma <- samples.row[ paste0("sigma[", seq_along(data$y), "]") ]
#   omega <- samples.row[[ "omega" ]]
#   alpha <- samples.row[[ "alpha" ]]
#   beta <- samples.row[[ "beta" ]]
#   
#   sum(dnorm(data$y, mu, 1/sqrt(sigma^2), log = TRUE)) +
#     dunif(sigma[1], 0, 10, log = TRUE) +
#     sum(dnorm(sigma[2:length(sigma)], sqrt(omega + alpha * (data$y[-1] - mu)^2 + beta * sigma[1:(length(sigma)-1)]^2), log = TRUE)) +
#     dnorm(mu, 0.0, 0.01, log = TRUE) +
#     dunif(omega, 0, 10, log = TRUE) +
#     dunif(alpha, 0, 1, log = TRUE) +
#     dunif(beta, 0, 1, log = TRUE)
# }

# Specify parameter bounds for ARCH model (H0)
# cn_ARCH <- colnames(arch_model$BUGSoutput$sims.matrix)
# cn_ARCH <- cn_ARCH[cn_ARCH != "deviance"]
# lb_ARCH <- rep(-Inf, length(cn_ARCH))
# ub_ARCH <- rep(Inf, length(cn_ARCH))
# names(lb_ARCH) <- names(ub_ARCH) <- cn_ARCH
# lb_ARCH[["sigma[1]"]] <- 0
# 
# # Specify parameter bounds for GARCH model (H1)
# cn_GARCH <- colnames(garch_model$BUGSoutput$sims.matrix)
# cn_GARCH <- cn_GARCH[cn_GARCH != "deviance"]
# lb_GARCH <- rep(-Inf, length(cn_GARCH))
# ub_GARCH <- rep(Inf, length(cn_GARCH))
# names(lb_GARCH) <- names(ub_GARCH) <- cn_GARCH
# lb_GARCH[["sigma[1]"]] <- 0


# # compute log marginal likelihood via bridge sampling for H0
# H0.bridge <- bridge_sampler(samples = arch_model, data = arch_model_data,
#                             log_posterior = log_posterior_ARCH, lb = lb_ARCH,
#                             ub = ub_ARCH, silent = FALSE)
# print(H0.bridge)

# compute log marginal likelihood via bridge sampling for H0
# H0.bridge <- bridge_sampler(samples = arch_model, data = arch_model_data,
#                             log_posterior = log_posterior_ARCH, lb = lb_ARCH,
#                             ub = ub_ARCH, silent = TRUE)
# print(H0.bridge)

