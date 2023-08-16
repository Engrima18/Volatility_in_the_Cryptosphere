library(R2jags)
source("functions.R")

y <- data$LogReturns
N <- length(y)

# Jags code to fit the model to the simulated data
garch_model_code <- "
model
{
  # Likelihood
  for (t in 1:N) {
    y[t] ~ dnorm(mu, tau[t])
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
garch_model_data <- list(N = N, y = y)

# Choose the parameters to watch
garch_model_parameters <- c("omega", "alpha", "beta", "mu", "sigma")

# Run the model
garch_model <- jags(
  data = garch_model_data,
  parameters.to.save = garch_model_parameters,
  model.file = textConnection(garch_model_code),
  n.chains = 3, # Number of different starting positions
  n.iter = 5000, # Number of iterations
  n.burnin = 200, # Number of iterations to remove at start
  n.thin = 2
)