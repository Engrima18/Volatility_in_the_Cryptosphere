library(R2jags)
source("functions.R")

y <- data$LogReturns
N <- length(y)


arch_model_code <- "
model
{
  # Likelihood
  for (t in 1:N) {
    y[t] ~ dnorm(mu, tau[t])
    tau[t] <- 1/pow(sigma[t], 2)
  }
  sigma[1] ~ dunif(0,10)
  for(t in 2:N) {
    sigma[t] <- sqrt(omega + alpha * pow(y[t-1] - mu, 2))
  }

  # Priors
  mu ~ dnorm(0.0, 0.01)
  omega ~ dunif(0, 10)
  alpha ~ dunif(0, 1)
}
"

# Set up the data
arch_model_data <- list(N = N, y = y)

# Choose the parameters to watch
arch_model_parameters <- c("omega", "alpha", "mu", "sigma")

# Run the model
arch_model <- jags(
  data = arch_model_data,
  parameters.to.save = arch_model_parameters,
  model.file = textConnection(arch_model_code),
  n.chains = 3, # Number of different starting positions
  n.iter = 5000, # Number of iterations
  n.burnin = 200, # Number of iterations to remove at start
  n.thin = 2
)
