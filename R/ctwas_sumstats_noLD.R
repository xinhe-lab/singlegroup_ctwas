#' @title run cTWAS analysis using summary statistics with "no LD" version
#'
#' @param z_snp A data frame with four columns: "id", "A1", "A2", "z".
#' giving the z scores for snps. "A1" is effect allele. "A2" is the other allele.
#'
#' @param weights a list of pre-processed prediction weights.
#'
#' @param region_info a data frame of region definitions.
#'
#' @param snp_map a list of data frames with SNP-to-region map for the reference.
#'
#' @param z_gene A data frame with columns: "id", "z", giving the z-scores for genes.
#'
#' @param niter_prefit the number of iterations of the E-M algorithm to perform during the initial parameter estimation step
#'
#' @param niter the number of iterations of the E-M algorithm to perform during the complete parameter estimation step
#'
#' @param thin The proportion of SNPs to be used for estimating parameters and screening regions.
#'
#' @param init_group_prior a vector of initial values of prior inclusion probabilities for SNPs and genes.
#'
#' @param init_group_prior_var a vector of initial values of prior variances for SNPs and gene effects.
#'
#' @param maxSNP Inf or integer. Maximum number of SNPs in a region. Default is
#' Inf, no limit. This can be useful if there are many SNPs in a region and you don't
#' have enough memory to run the program.
#'
#' @param min_nonSNP_PIP Regions with non-SNP PIP >= \code{min_nonSNP_PIP}
#' will be selected to run finemapping using full SNPs.
#'
#' @param min_p_single_effect Regions with probability >= \code{min_p_single_effect}
#' of having at most one causal effect will be selected for the final EM step.
#'
#' @param use_null_weight If TRUE, allow for a probability of no effect in susie.
#'
#' @param outputdir The directory to store output. If specified, save outputs to the directory.
#'
#' @param outname The output name.
#'
#' @param ncore The number of cores used to parallelize susie over regions
#'
#' @param logfile The log filename. If NULL, print log info on screen.
#'
#' @param verbose If TRUE, print detailed messages
#'
#' @param ... Additional arguments of \code{susie_rss}.
#'
#' @importFrom logging addHandler loginfo writeToFile
#' @importFrom utils packageVersion
#'
#' @return a list, including z_gene, estimated parameters, region_data,
#' cross-boundary genes, screening region results, and fine-mapping results.
#'
#' @export
#'
ctwas_sumstats_noLD <- function(
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
    ...){

  if (!is.null(logfile)) {
    addHandler(writeToFile, file=logfile, level='DEBUG')
  }

  loginfo("Running cTWAS analysis without LD ...")
  loginfo("ctwas version: %s", packageVersion("ctwas"))

  # check inputs
  if (anyNA(z_snp))
    stop("z_snp contains missing values!")

  if (!inherits(weights,"list"))
    stop("'weights' should be a list object.")

  if (any(sapply(weights, is.null)))
    stop("weights contain NULL, remove empty weights!")

  if (!inherits(snp_map,"list"))
    stop("'snp_map' should be a list.")

  if (thin > 1 | thin <= 0)
    stop("thin needs to be in (0,1]")

  if (!is.null(outputdir)) {
    dir.create(outputdir, showWarnings=FALSE, recursive=TRUE)
  }

  loginfo("ncore: %d", ncore)

  # Compute gene z-scores
  if (is.null(z_gene)) {
    z_gene <- compute_gene_z(z_snp, weights, ncore = ncore)
    if (!is.null(outputdir)) {
      saveRDS(z_gene, file.path(outputdir, paste0(outname, ".z_gene.RDS")))
    }
  }

  if (anyNA(z_gene)){
    stop("z_gene contains missing values!")
  }

  # Get region_data, which contains SNPs and genes assigned to each region
  #. downsample SNPs if thin < 1
  #. assign SNP and gene IDs, and z-scores to each region
  #. find boundary genes and adjust region_data for boundary genes
  region_data_res <- assemble_region_data(region_info,
                                          z_snp,
                                          z_gene,
                                          weights,
                                          snp_map,
                                          thin = thin,
                                          maxSNP = maxSNP,
                                          trim_by = "random",
                                          adjust_boundary_genes = TRUE,
                                          ncore = ncore)
  region_data <- region_data_res$region_data
  boundary_genes <- region_data_res$boundary_genes
  if (!is.null(outputdir)) {
    saveRDS(region_data, file.path(outputdir, paste0(outname, ".region_data.thin", thin, ".RDS")))
    saveRDS(boundary_genes, file.path(outputdir, paste0(outname, ".boundary_genes.RDS")))
  }

  # Estimate parameters
  #. get region_data for all the regions
  #. run EM for two rounds with thinned SNPs using L = 1
  param <- est_param(region_data,
                     init_group_prior = init_group_prior,
                     init_group_prior_var = init_group_prior_var,
                     niter_prefit = niter_prefit,
                     niter = niter,
                     min_p_single_effect = min_p_single_effect,
                     ncore = ncore,
                     verbose = verbose)

  group_prior <- param$group_prior
  group_prior_var <- param$group_prior_var
  if (!is.null(outputdir)) {
    saveRDS(param, file.path(outputdir, paste0(outname, ".param.RDS")))
  }

  # Screen regions
  #. fine-map all regions with thinned SNPs
  #. select regions with strong non-SNP signals
  screen_res <- screen_regions_noLD(region_data,
                                    group_prior = group_prior,
                                    group_prior_var = group_prior_var,
                                    min_nonSNP_PIP = min_nonSNP_PIP,
                                    ncore = ncore,
                                    verbose = verbose,
                                    ...)
  screened_region_data <- screen_res$screened_region_data

  # expand selected regions with all SNPs
  if (thin < 1){
    screened_region_data <- expand_region_data(screened_region_data,
                                               snp_map,
                                               z_snp,
                                               maxSNP = maxSNP,
                                               ncore = ncore)
    screen_res$screened_region_data <- screened_region_data
  }

  if (!is.null(outputdir)) {
    saveRDS(screen_res, file.path(outputdir, paste0(outname, ".screen_res.RDS")))
  }

  # Run fine-mapping for regions with strong gene signals using full SNPs
  if (length(screened_region_data) > 0){
    finemap_res <- finemap_regions_noLD(screened_region_data,
                                        group_prior = group_prior,
                                        group_prior_var = group_prior_var,
                                        use_null_weight = use_null_weight,
                                        ncore = ncore,
                                        verbose = verbose,
                                        ...)
    if (!is.null(outputdir)) {
      saveRDS(finemap_res, file.path(outputdir, paste0(outname, ".finemap_res.RDS")))
    }
  } else {
    loginfo("No regions selected for finemapping.")
    finemap_res <- NULL
  }

  return(list("z_gene" = z_gene,
              "param" = param,
              "finemap_res" = finemap_res,
              "region_data" = region_data,
              "boundary_genes" = boundary_genes,
              "screen_res" = screen_res))

}

