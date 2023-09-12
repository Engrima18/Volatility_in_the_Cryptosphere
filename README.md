# Volatility_in_the_Cryptosphere

This project addresses the study and construction of econometric models in Bayesian frame-
work that can capture the volatility of bitcoin.

<img src="https://github.com/Engrima18/Volatility_in_the_Cryptosphere/assets/93355495/03cfeea8-8d62-4bab-9a2c-af6bd2e58198" align="left"> 

</br>

Various Bayesian hierarchical models will then be improved by adjustment of the MCMC-based sampling process and reformulation of prior
beliefs.
The main goal is to build a useful tool in decision analysis/risk management and in general
try to infer the main critical factors when investing on assets of this type.

## The data set

The [Yahoo Finance Bitcoin Historical Data](https://www.kaggle.com/datasets/arslanr369/bitcoin-price-2014-2023) from Kaggle, spanning from 2014 to 2023, capture the evolution of Bitcoin’s price over a decade. We are only interested in the adjusted closing
price of bitcoin (in terms of BTC/USD value), from which we also derive the “LogREturns”
feature.

We report below the decomposition results for prices and returns considering that we have
one observation per day (for 9 years).