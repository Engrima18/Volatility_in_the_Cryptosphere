library(R2jags)
source("scripts/functions.R")

y <- data$LogReturns
N <- length(y)

# Jags code to fit the model to the simulated data
fore_model_code <- "
model
{
  # Likelihood
  for (t in 1:N) {
    y[t] ~ dt(mu, tau[t], 8)
    tau[t] <- 1/pow(sigma[t], 2)
  }
  sigma[1] ~ dunif(0,10)
  for(t in 2:N) {
    sigma[t] <- sqrt(omega + alpha * pow(y[t-1] - mu, 2) + beta * pow(sigma[t-1], 2))
  }

  # Priors
  mu ~ dnorm(0.0, 0.01)
  omega ~ dunif(0, 10)
  alpha ~ dunif(0, 1)
  beta ~ dunif(0, 1)
}
"

# Set up the data
fore_model_data <- list(N = N + 20, y = c(y, rep(NA, 20)))

# Choose the parameters to watch
fore_model_parameters <- c("y", "sigma")

# Run the model
fore_garch_model <- jags(
  data = fore_model_data,
  parameters.to.save = fore_model_parameters,
  model.file = textConnection(fore_model_code),
  n.chains = 3, # Number of different starting positions
  n.iter = 5000, # Number of iterations
  n.burnin = 200, # Number of iterations to remove at start
  n.thin = 2
)