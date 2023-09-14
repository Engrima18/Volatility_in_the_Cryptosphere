# Volatility_in_the_Cryptosphere


Quick advice: if you are ralemnte interested in understanding the work done and the results obtained read the official project report contained in the `BTC_analysis.pdf` file in this repo.

<img align="left" width="260" height="200" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/c71b9253-abd8-446f-9190-f1e41a30559b"> 

This project addresses the study and construction of econometric models in Bayesian frame-
work that can capture the volatility of bitcoin.
Various Bayesian models will then be improved by adjustment of the MCMC-based sampling process and reformulation of prior
beliefs.
The main goal is to build a useful tool in decision analysis/risk management and in general
try to infer the main critical factors when investing on assets of this type.

<br/>
<br/>

## The data set

The [Yahoo Finance Bitcoin Historical Data](https://www.kaggle.com/datasets/arslanr369/bitcoin-price-2014-2023) from Kaggle, spanning from 2014 to 2023, capture the evolution of Bitcoin’s price over a decade. We are only interested in the adjusted closing
price of bitcoin (in terms of BTC/USD value), from which we also derive the “LogREturns”
feature.

<img alt="data" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/faae5bc7-bffd-4062-bb8c-38e6044f3d2e" align="center">

\

We report below the decomposition results for prices and returns considering that we have
one observation per day (for 9 years).

| <!-- -->    | <!-- -->    | 
|-------------|-------------|
<img alt="proces" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/9b355bc3-2baa-4c0e-a0cf-2ec579185e0a"> |<img alt="returns" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/b455e264-f32c-4d6b-87d7-de0b680dd89a">

The following ACF plot suggests that the scale of returns changes in
time and the (conditional) variance of the process is time varying.

<img alt="acfs" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/74394703-3265-445b-98d8-6b720d4f3046">

 In order to capture
volatility clustering, we need to introduce appropriate time series processes able to model
this behavior!


## The model(s)

Our model will have to adhere to a number of features
to enable consistent results to be obtained:

1. It need not be robust to modeling any trends, patterns or forms of seasonality
2. Instead, it must provide for strong heteroscedasticity.
3. It can be based on the assumption of stationarity of the data.


We use three JAGS (MCMC based) models typically used in econometrics for volatility forecasting:

>- ARCH(1)
>- GARCH(1, 1)
>- t-student GARCH(1, 1)

Then we compare the results of our models and select the one with minimum DIC.

| <!-- -->    | <!-- -->    | 
|-------------|-------------|
<img alt="comparison1" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/7541fe7d-a4e4-4be4-8552-3b84eda57864"> |<img alt="forecasting" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/b29ed5af-7ec1-409d-861c-8bba8e1517e0">

The winner is the Bayesian GARCH(1,1) model with a **non-central t-student** prior distribution for returns:

$$
\begin{aligned}
y_t &= \sqrt{\sigma^2_t} \cdot z_t \nonumber \\
\sigma^2_t &= \omega + \alpha y^2_{t-1} + \beta \sigma_{t-1}^2
\end{aligned}
$$

$$
\begin{aligned}
y_t &\sim t(\mu, \sigma_t^2, \nu) \nonumber \\
\mu &\sim N(0, 100^2) \nonumber \\
\omega &\sim U(0, 10) \nonumber \\
\alpha &\sim U(0, 1) \nonumber \\
\beta &\sim U(0, 1)
\end{aligned}
$$

where:

>- $\delta = \mu \cdot \sigma^{- \frac{1}{2}}_t$ is the non-centrality parameter
>- $\nu = 8$ represents the degrees of freedom and we set it equal to a constant

This variables and parameters have a specific meaning in our model:

>- $y_t$ is the observed value at time t
>- $z_t$ is the white noise (innovation) term at time t
>- $\sigma_t^2$ is the conditional variance of $y_t$ 
>- $\omega$ is the baseline volatility
>- $\alpha$ represents the impact of past squared residuals on the conditional variance


Here the JAGS code:

```{r}
tstud_model_code <- "
model
{
  # Likelihood
  for (t in 1:N) {
    y[t] ~ dt(mu, tau[t], 8)
    tau[t] <- 1/pow(sigma[t], 2)
  }
  sigma[1] ~ dunif(0,10)
  for(t in 2:N) {
    sigma[t] <- sqrt(omega + alpha * pow(y[t-1] - mu, 2) +
                     beta * pow(sigma[t-1], 2))
  }

  # Priors
  mu ~ dnorm(0.0, 0.01)
  omega ~ dunif(0, 10)
  alpha ~ dunif(0, 1)
  beta ~ dunif(0, 1)
}
"
```


## Convergence analysis

Our model is based on Markov Chain Monte Carlo sampling technique (Gibbs sampling) and we have to check for the convergence of its parameters to the target distributions.

| <!-- -->    | <!-- -->    | 
|-------------|-------------|
<img width="461" alt="con1" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/76eb02e4-58cd-4ea7-b719-5b4cd3a353fc"> |<img width="476" alt="con2" src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/4a900d05-8236-430c-83c4-774341263ec5">

## Used technologies


![RStudio](https://img.shields.io/badge/RStudio-4285F4?style=for-the-badge&logo=rstudio&logoColor=white)
![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)




