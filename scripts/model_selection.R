load("BTC.RData")


# inferencial findings ----------------------------------------------------

arch_res <- as.data.frame(
  MCMCsummary(arch_model, 
              params = setdiff(arch_model_parameters, "sigma"), 
              HPD = TRUE, 
              hpd_prob = 0.95, 
              round = 8))

garch_res <- as.data.frame(MCMCsummary(garch_model, 
                                       params = setdiff(garch_model_parameters, "sigma"), 
                                       HPD = TRUE, 
                                       hpd_prob = 0.95, 
                                       round = 8))

tgarch_res <- as.data.frame(MCMCsummary(tstud_garch_model, 
                                        params = setdiff(tstud_model_parameters, "sigma"), 
                                        HPD = TRUE, 
                                        hpd_prob = 0.95, 
                                        round = 8))

# DIC comparison df -------------------------------------------------------

model_comparison <- data.frame(
  Model = c("ARCH", "GARCH", "t Student GARCH"),
  DIC = c(arch_model$BUGSoutput$DIC , garch_model$BUGSoutput$DIC,
          tstud_garch_model$BUGSoutput$DIC),
  n.chains = c(arch_model$BUGSoutput$n.chains , garch_model$BUGSoutput$n.chains,
               tstud_garch_model$BUGSoutput$n.chains),
  n.iter = c(arch_model$BUGSoutput$n.iter , garch_model$BUGSoutput$n.iter,
             tstud_garch_model$BUGSoutput$n.iter),
  pD = c(arch_model$BUGSoutput$pD , garch_model$BUGSoutput$pD,
         tstud_garch_model$BUGSoutput$pD))


# ESS comparison df -------------------------------------------------------

ess1 <- effectiveSize(arch_model)
ess2 <- effectiveSize(garch_model)
ess3 <- effectiveSize(tstud_garch_model)

es <- data.frame(
  Model = c("ARCH", "GARCH", "t Student GARCH"),
  omega = c(ess1[["omega"]], ess2[["omega"]], ess3[["omega"]]),
  alpha = c(ess1[["alpha"]], ess2[["alpha"]], ess3[["alpha"]]),
  beta = c(NA, ess2[["beta"]], ess3[["beta"]]),
  mu = c(ess1[["mu"]], ess2[["mu"]], ess3[["mu"]]),
  deviance =  c(ess1[["deviance"]], ess2[["deviance"]], ess3[["deviance"]])
)

