% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ctwas_finemapping.R
\name{finemap_single_region}
\alias{finemap_single_region}
\title{Runs cTWAS finemapping for a single region}
\usage{
finemap_single_region(
  region_data,
  region_id,
  LD_map,
  weights,
  L = 5,
  group_prior = NULL,
  group_prior_var = NULL,
  use_null_weight = TRUE,
  coverage = 0.95,
  min_abs_corr = 0.1,
  include_cs_index = TRUE,
  snps_only = FALSE,
  force_compute_cor = FALSE,
  save_cor = FALSE,
  cor_dir = NULL,
  LD_format = c("rds", "rdata", "mtx", "csv", "txt", "custom"),
  LD_loader_fun = NULL,
  verbose = FALSE,
  ...
)
}
\arguments{
\item{region_data}{a list object with data for the regions}

\item{region_id}{a character string of region id to be finemapped}

\item{LD_map}{a data frame with filenames of LD matrices and SNP information for the regions.}

\item{weights}{a list of preprocessed weights.}

\item{L}{the number of effects for susie during the fine mapping}

\item{group_prior}{a vector of two prior inclusion probabilities for SNPs and genes.}

\item{group_prior_var}{a vector of two prior variances for SNPs and gene effects.}

\item{use_null_weight}{If TRUE, allow for a probability of no effect in susie}

\item{coverage}{A number between 0 and 1 specifying the \dQuote{coverage} of the estimated confidence sets}

\item{min_abs_corr}{Minimum absolute correlation allowed in a credible set.}

\item{include_cs_index}{If TRUE, add cs_index to finemapping results.}

\item{snps_only}{If TRUE, use only SNPs in the region data.}

\item{force_compute_cor}{If TRUE, force computing correlation (R) matrices.}

\item{save_cor}{If TRUE, save correlation (R) matrices to \code{cor_dir}}

\item{cor_dir}{a string, the directory to store correlation (R) matrices}

\item{LD_format}{file format for LD matrix. If "custom", use a user defined
\code{LD_loader_fun()} function to load LD matrix.}

\item{LD_loader_fun}{a user defined function to load LD matrix when \code{LD_format = "custom"}.}

\item{verbose}{If TRUE, print detail messages}

\item{...}{Additional arguments of \code{susie_rss}.}
}
\value{
a data frame of finemapping results.
}
\description{
Runs cTWAS finemapping for a single region
}
\keyword{internal}
