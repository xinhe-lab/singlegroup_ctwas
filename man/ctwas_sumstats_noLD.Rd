% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ctwas_sumstats_noLD.R
\name{ctwas_sumstats_noLD}
\alias{ctwas_sumstats_noLD}
\title{run cTWAS analysis using summary statistics with "no LD" version}
\usage{
ctwas_sumstats_noLD(
  z_snp,
  weights,
  region_info,
  snp_map,
  z_gene = NULL,
  thin = 0.1,
  niter_prefit = 3,
  niter = 30,
  init_group_prior = NULL,
  init_group_prior_var = NULL,
  maxSNP = Inf,
  min_nonSNP_PIP = 0.5,
  min_p_single_effect = 0.8,
  use_null_weight = TRUE,
  outputdir = NULL,
  outname = "ctwas_noLD",
  ncore = 1,
  logfile = NULL,
  verbose = FALSE,
  ...
)
}
\arguments{
\item{z_snp}{A data frame with four columns: "id", "A1", "A2", "z".
giving the z scores for snps. "A1" is effect allele. "A2" is the other allele.}

\item{weights}{a list of pre-processed prediction weights.}

\item{region_info}{a data frame of region definitions.}

\item{snp_map}{a list of data frames with SNP-to-region map for the reference.}

\item{z_gene}{A data frame with columns: "id", "z", giving the z-scores for genes.}

\item{thin}{The proportion of SNPs to be used for estimating parameters and screening regions.}

\item{niter_prefit}{the number of iterations of the E-M algorithm to perform during the initial parameter estimation step}

\item{niter}{the number of iterations of the E-M algorithm to perform during the complete parameter estimation step}

\item{init_group_prior}{a vector of initial values of prior inclusion probabilities for SNPs and genes.}

\item{init_group_prior_var}{a vector of initial values of prior variances for SNPs and gene effects.}

\item{maxSNP}{Inf or integer. Maximum number of SNPs in a region. Default is
Inf, no limit. This can be useful if there are many SNPs in a region and you don't
have enough memory to run the program.}

\item{min_nonSNP_PIP}{Regions with non-SNP PIP >= \code{min_nonSNP_PIP}
will be selected to run finemapping using full SNPs.}

\item{min_p_single_effect}{Regions with probability >= \code{min_p_single_effect}
of having at most one causal effect will be selected for the final EM step.}

\item{use_null_weight}{If TRUE, allow for a probability of no effect in susie.}

\item{outputdir}{The directory to store output. If specified, save outputs to the directory.}

\item{outname}{The output name.}

\item{ncore}{The number of cores used to parallelize susie over regions}

\item{logfile}{The log filename. If NULL, print log info on screen.}

\item{verbose}{If TRUE, print detailed messages}

\item{...}{Additional arguments of \code{susie_rss}.}
}
\value{
a list, including z_gene, estimated parameters, region_data,
cross-boundary genes, screening region results, and fine-mapping results.
}
\description{
run cTWAS analysis using summary statistics with "no LD" version
}
