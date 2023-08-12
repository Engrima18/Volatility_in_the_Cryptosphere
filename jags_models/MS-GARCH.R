library(R2jags)

# Jags code to fit the model to the simulated data
model_code <- "
model {
  # Priors for transition probabilities
  for (i in 1:K) {
    
  }
  
  # Likelihood for regime-switching GARCH
  sigma[1] ~ dunif(0,10)
  for (t in 1:T) {
    # State transition
    s[t] ~ dcat(pi)
    
    # GARCH volatility calculation for each state
    for (k in 1:K) {
      # check the current state
      if (s[t] == k) {
        sigma[t] <- sqrt(omega[k] + alpha[k] *  pow(y[t-1] - mu[k], 2) + beta[k] *pow(sigma[t-1], 2))
        y[t] ~ dnorm(0, tau[t])
        tau[t] <- 1/pow(sigma[t], 2)
      }
    }
  }
  
  # Priors for GARCH parameters within each regime
  # and transition probabilities
  for (k in 1:K) {
    pi[k] ~ dunif(0, 1)
    mu[k] ~ dnorm(0.0, 0.01)
    omega[k] ~ dunif(0, 10)
    alpha[k] ~ dunif(0, 1)
    beta[k] ~ dunif(0, 1)
  }
}
"

# Set up the data
model_data <- list(T = T, K = K, y = y)

# Choose the parameters to watch
model_parameters <- c("omega", "alpha", "beta", "mu", "pi")

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

