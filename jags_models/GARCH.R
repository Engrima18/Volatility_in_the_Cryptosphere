library(R2jags)

# Jags code to fit the model to the simulated data
model_code <- "
model
{
  # Likelihood
  for (t in 1:T) {
    y[t] ~ dnorm(mu, tau[t])
    tau[t] <- 1/pow(sigma[t], 2)
  }
  sigma[1] ~ dunif(0,10)
  for(t in 2:T) {
    sigma[t] <- sqrt( omega + alpha * pow(y[t-1] - mu, 2) + beta * pow(sigma[t-1], 2))
  }

  # Priors
  mu ~ dnorm(0.0, 0.01)
  omega ~ dunif(0, 10)
  alpha ~ dunif(0, 1)
  beta ~ dunif(0, 1)
}
"

# Set up the data
model_data <- list(T = T, y = y)

# Choose the parameters to watch
model_parameters <- c("omega", "alpha", "beta", "mu")

# Run the model
model_run <- jags(
  data = model_data,
  parameters.to.save = model_parameters,
  model.file = textConnection(model_code),
  n.chains = 4, # Number of different starting positions
  n.iter = 1000, # Number of iterations
  n.burnin = 200, # Number of iterations to remove at start
  n.thin = 2
)