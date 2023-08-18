library(R2jags)

data <- read.csv("BTC-USD.csv")
y <- data$Adj.Close
K <- 2
N <- length(y)

# Jags code to fit the model to the simulated data
model_code <- "
model {
  
 # Likelihood
  for (t in 1:N) {
    # Regime probabilities
    s[t] ~ dcat(pi)
    
    for (k in 1:K) {
      # check the current state
      indicator[t, k] <- (s[t] == k)
      y[t] ~ dnorm(mu[k], tau[t]) * indicator[t, k]
      tau[t] <- 1 / pow(sigma[t, k], 2)
    }
  }
  
  # Volatility equation for each regime
  for (k in 1:K) {
    sigma[1, k] ~ dunif(0, 10)
    for(t in 2:N) {
      sigma[t, k] <- sqrt(omega[k] + alpha[k] * pow(y[t-1] - mu[k], 2) + beta[k] * pow(sigma[t-1, k], 2))
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
model_data <- list(N = N, K = K, y = y)

# Choose the parameters to watch
model_parameters <- c("omega", "alpha", "beta", "mu", "pi")

# Run the model
msgarch_model <- jags(
  data = model_data,
  parameters.to.save = model_parameters,
  model.file = textConnection(model_code),
  n.chains = 3, # Number of different starting positions
  n.iter = 1000, # Number of iterations
  n.burnin = 200, # Number of iterations to remove at start
  n.thin = 2
)

